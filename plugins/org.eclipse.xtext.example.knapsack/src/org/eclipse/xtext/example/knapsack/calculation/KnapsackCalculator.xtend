package org.eclipse.xtext.example.knapsack.calculation

import java.math.BigDecimal
import java.math.BigInteger
import java.text.DecimalFormat
import java.util.List
import java.util.concurrent.Callable
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.Future
import org.eclipse.xtext.example.knapsack.knapsack.Algorithm
import org.eclipse.xtext.example.knapsack.knapsack.Item
import org.eclipse.xtext.example.knapsack.knapsack.KnapsackProblem
import org.eclipse.xtext.xbase.lib.IntegerRange
import org.eclipse.xtext.xbase.lib.Pair

import static org.eclipse.xtext.example.knapsack.knapsack.Algorithm.*

import static extension com.google.common.collect.Sets.*
import static extension java.lang.Integer.*
import static extension java.lang.Math.*

class KnapsackCalculator {

    def calculateOptimum(KnapsackProblem it) {
    	(packedItem && unpackedItem).calculateOptimum(algorithm, capacity)
    }
    
    def private calculateOptimum(Iterable<Item> it, Algorithm algorithm, int capacity) {
    	switch(algorithm) {
    		case GREEDY: 	calculateOptimumByGreedyAlgorithm(capacity)
    		case RECURSION: calculateOptimumByRecursion(capacity)
    		case DP: 		calculateOptimumByDynamicProgramming(capacity)
    		case COMPLETE: 	calculateOptimumByComplete(capacity)
    		default: 		calculateOptimumByGreedyAlgorithm(capacity)
    	}
    }
    
	def private calculateOptimumByGreedyAlgorithm(Iterable<Item> it, int capacity) {
		// div result is int in IntegerExtensions? -> Ok, as so defined in Java Spec
		val sorted = toList.sortBy[-(value / weight)] 
		val index = (0..size)
						.map[it -> sorted.subList(0, it).map[weight].reduce[w1, w2 | w1 + w2]]
						.filter[it.value != null && it.value <= capacity].last?.key
		if(index != null && index > 0) sorted.subList(0, index) else #[]
	}    
    
	def private calculateOptimumByRecursion(Iterable<Item> items, int capacity) {
		val selectedItems = <Item>newArrayList
		items.toList.calculateOptimumByRecursion(capacity, 0, selectedItems).value
	}
	
	def private Pair<Integer, ? extends List<Item>> calculateOptimumByRecursion(
			List<Item> it, int capacity, int index, List<Item> selectedItems) {
		if(index < size) {
    		val a = calculateOptimumByRecursion(capacity, index + 1, selectedItems);
	    	val item = get(index)
	    	var b = 
	    		if(capacity - item.weight >= 0) {
	    			val result = calculateOptimumByRecursion(capacity - item.weight, index + 1, selectedItems)
					val newSelectedItems = <Item>newArrayList
	    			result.value.forEach[newSelectedItems += it]
	    			newSelectedItems += item
	      			item.value + result.key -> newSelectedItems
	    		} else 0 -> selectedItems
	    	if(a.key > b.key) {
	    		return a
	    	} else {
	    		return b
    		}
  		} else 0 -> selectedItems
	}
	
	def private calculateOptimumByDynamicProgramming(Iterable<Item> it, int capacity) {
		calculateOptimumByGreedyAlgorithm(capacity)
	}    
	
    def calculateOptimumByComplete(Iterable<Item> it, int capacity) {
    	val list = toList
    	val combinations = if(size == 0) 0 else (2 ** size).intValue - 1
    	//val extension (String) => int toInt = [Integer.valueOf(it)] // is not available
    	val range = sqrt(combinations).intValue
    	val processRanges = (0..(combinations / range).intValue)
    							.map[new IntegerRange(range * it, maxRange(range, combinations))]
    	val executorService = Executors.newCachedThreadPool
		processRanges
			.map[new CompleteCalculationTask(start, end, list, capacity)]
			.parallelize(executorService).map[get]
			.flatten.sortBy[-value].map[key].head
    }
    
    def maxRange(int index, int range, int combinations) {
    	var maxRange = (range * index) + range; 
    	if(maxRange < combinations) maxRange else combinations; 
    }
    
    def private <T> List<Future<T>> parallelize(Iterable<? extends Callable<T>> callables, extension ExecutorService executorService) {
    	callables.toList.invokeAll
    }
	
    def private operator_and(Iterable<Item> items1, Iterable<Item> items2) {
    	(items1.nullSafeSet.union(items2.nullSafeSet))
    }	
    
    def private nullSafeSet(Iterable<Item> items) {
    	if(items != null) items.toSet else newHashSet
    }
    
    def private operator_power(int base, int exponent) {  base.pow(exponent)  }
    
    def private BigDecimal operator_divide(int a, int b) {  return BigDecimal.valueOf(a) / BigDecimal.valueOf(b) }
}

@Data
class CompleteCalculationTask implements Callable<Iterable<Pair<Iterable<Item>, Integer>>> {
	
	int start
	int end
	List<Item> list 
	int capacity

	override call() throws Exception {
    	val extension formatter = new DecimalFormat((1..list.size).map["0"].join)
		(start..end)
			.map[toBinaryString.toInt.format.toCharArray]
			.map[getItems(list, capacity)].filter[size > 0]
			.map[it -> map[value].reduce[v1, v2|v1 + v2]] // reduce[+]
	}

    def private toInt(String s) { new BigInteger(s)  }

    def private getItems(char[] binaryList, Iterable<Item> itemList, int capacity) {
    	val items = (0..binaryList.size-1).map[getItemForBinaryPosition(binaryList, itemList)].filter[it != null]
    	val sum = items.map[weight].reduce[w1, w2|w1 + w2] 	
    	if(sum != null && sum <= capacity) items else #[]
    }

    def private getItemForBinaryPosition(int index, char[] binaryList, Iterable<Item> itemList) {
    	val value = binaryList.get(index).toString
    	switch(value) { case "1": itemList.get(index)  default: null  }
    }
}