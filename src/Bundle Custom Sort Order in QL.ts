export async function onBeforeCalculate(quote, lines, conn) {
    console.log("QCP Execution Started");

    try {
        if (!lines || lines.length === 0) {
            console.log("No lines found in the quote.");
            return;
        }

        // Map to track product occurrences
        let productCountMap = {};

        // Fetch Sort Orders from Product2
        let productIds = lines.map(line => line.record.SBQQ__Product__c).filter(Boolean);
        console.log("Product IDs in Quote:", productIds);

        if (productIds.length === 0) {
            console.log("No valid Product IDs found in quote lines.");
            return;
        }

        let productRecords = await conn.query(
            `SELECT Id, SBQQ__SortOrder__c FROM Product2 WHERE Id IN ('${productIds.join("','")}')`
        );

        console.log("Fetched Product Records:", productRecords);

        let productSortMap = {};
        productRecords.records.forEach(prod => {
            productSortMap[prod.Id] = prod.SBQQ__SortOrder__c || 100; // Default to 100 if null
        });

        console.log("Product Sort Order Map:", productSortMap);

        // Processing each quote line
        lines.forEach(line => {
            let productId = line.record.SBQQ__Product__c;
            if (!productId) {
                console.log("Skipping line with no product ID:", line.record);
                return;
            }

            let isBundleOption = line.record.SBQQ__BundledQuantity__c > 0; // Identifies bundle options
            let parentBundleId = line.record.SBQQ__Bundle__c; // Identifies parent bundle

            // Track occurrences of products/bundles
            if (!productCountMap[productId]) {
                productCountMap[productId] = 1; // First occurrence
            } else {
                productCountMap[productId]++; // Increment count for repeated occurrences
            }

            let occurrence = productCountMap[productId];
            console.log(`Processing Product: ${productId}, Occurrence: ${occurrence}, Is Bundle Option: ${isBundleOption}, Parent Bundle: ${parentBundleId}`);

            if (occurrence === 1) {
                // First occurrence, assign product's original sort order
                let sortOrder = productSortMap[productId] || 100;
                line.record.Custom_Sort_Order__c = sortOrder;
                console.log(`First occurrence - Assigned Sort Order: ${sortOrder}`);
            } else {
                // Subsequent occurrences, add +100 to the previous sort order
                let previousSortOrder = productSortMap[productId] || 100;
                let newSortOrder = previousSortOrder + (occurrence - 1) * 100;

                line.record.Custom_Sort_Order__c = newSortOrder;
                console.log(`Duplicate occurrence - Assigned New Sort Order: ${newSortOrder}`);

                // Ensure bundle options get the same adjusted sort order as their parent bundle
                if (isBundleOption && parentBundleId) {
                    line.record.Custom_Sort_Order__c = newSortOrder;
                    console.log(`Bundle Option - Assigned Same Sort Order as Parent: ${newSortOrder}`);
                }
            }
        });

        console.log("QCP Execution Completed");

    } catch (error) {
        console.error("Error in onBeforeCalculate:", error);
    }
}