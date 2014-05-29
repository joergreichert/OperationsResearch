/*
 * generated by Xtext
 */
package org.eclipse.xtext.example.knapsack.validation

import com.google.inject.Inject
import org.eclipse.xtext.example.knapsack.calculation.KnapsackCalculator
import org.eclipse.xtext.example.knapsack.knapsack.KnapsackPackage
import org.eclipse.xtext.example.knapsack.knapsack.KnapsackProblem
import org.eclipse.xtext.validation.Check
import org.eclipse.xtext.validation.ValidationMessageAcceptor

import static extension com.google.common.collect.Sets.*
import org.eclipse.xtext.validation.CheckType
import org.eclipse.xtext.example.knapsack.knapsack.Item
import java.util.List
import static org.eclipse.xtext.example.knapsack.validation.IssueCodes.*

class KnapsackValidator extends AbstractKnapsackValidator {
	@Inject extension KnapsackCalculator

    @Check(value=CheckType.EXPENSIVE)
    def checkCompilation(KnapsackProblem it) {
    	val start = System.currentTimeMillis
    	try {
    		val expected = calculateOptimum
	    	val end = System.currentTimeMillis
	    	val actual = packedItem
	    	
	        if (expected.size != actual.size || (actual.size > 0 && !(0..actual.size-1).exists(index|expected.get(index) == actual.get(index)))) {
	    		val allItems = packedItem.toSet.union(unpackedItem.toSet).toList
	    		val allItemsSize = allItems.size 
				val newUnpackedItems = allItems
				newUnpackedItems.removeAll(expected)
				val expectedStr = expected.map[name].join(SEPERATOR)     	
				val newUnpackedItemsStr = newUnpackedItems.map[name].join(SEPERATOR)
				val lastDurationMessage = '''Last calculation applying algorithm «algorithm.getName()» on «allItemsSize» items took «end-start» ms.'''.toString     	
	            warning(
	            	"Current packaging is not the optimum", 
	            	KnapsackPackage$Literals::KNAPSACK_PROBLEM__CAPACITY,
	            	ValidationMessageAcceptor::INSIGNIFICANT_INDEX,
	            	IssueCodes::WRONG_ASSEMBLY, 
	            	expectedStr, newUnpackedItemsStr, lastDurationMessage
	            );
	        }
    	} catch(Exception e) {
    		error(
            	e.message,
            	KnapsackPackage$Literals::KNAPSACK_PROBLEM__CAPACITY,
            	ValidationMessageAcceptor::INSIGNIFICANT_INDEX
            );
            e.printStackTrace
    	}
    }

    @Check
    def checkUniqueNames(KnapsackProblem it) {
   		var allItems = packedItem.toSet.union(unpackedItem.toSet).toList
   		var itemsToMark = collectDuplicates(allItems, newArrayList)
   		itemsToMark.forEach[
    		error(
            	"Duplicate name " + name,
            	eContainer,
            	eContainingFeature,
            	(eContainer.eGet(eContainingFeature) as List<Item>).indexOf(it)
            );
   		]
    }
    
    def List<Item> collectDuplicates(List<Item> allItems, List<Item> itemsToMark) {
    	val item = allItems.head
    	if(item != null) {
			val duplicates = allItems.filter[it != item && name == item.name].toList
			duplicates += item
			if(duplicates.size > 1) {
				itemsToMark.addAll(duplicates)
			}
			allItems.removeAll(duplicates)
			return if(allItems.size > 0) collectDuplicates(allItems, itemsToMark) else itemsToMark
		}
		itemsToMark
    }
}