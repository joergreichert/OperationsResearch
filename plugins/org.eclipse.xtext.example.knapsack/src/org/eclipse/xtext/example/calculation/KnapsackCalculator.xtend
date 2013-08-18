package org.eclipse.xtext.example.calculation

import java.text.DecimalFormat
import java.util.List
import org.eclipse.xtext.example.knapsack.Algorithm
import org.eclipse.xtext.example.knapsack.Item
import org.eclipse.xtext.example.knapsack.KnapsackProblem
import org.eclipse.xtext.xbase.lib.Pair

import static org.eclipse.xtext.example.knapsack.Algorithm.*

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
		val sorted = toList.sortBy[-(value / weight)]
		val index = (0..size).map[it -> sorted.subList(0, it).map[weight].reduce[w1, w2 | w1 + w2]].filter[it.value != null && it.value <= capacity].last.key
		if(index != null && index > 0) sorted.subList(0, index) else #[]
	}    
    
	def private calculateOptimumByRecursion(Iterable<Item> items, int capacity) {
		val selectedItems = <Item>newArrayList
		items.toList.calculateOptimumByRecursion(capacity, 0, selectedItems).value
	}
	
	def private Pair<Integer, ? extends List<Item>> calculateOptimumByRecursion(List<Item> it, int capacity, int index, List<Item> selectedItems) {
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
    	val extension formatter = new DecimalFormat((1..size).map["0"].join)
    	//val extension (String) => int toInt = [Integer.valueOf(it)] // is not available
		(0..combinations)
			.map[toBinaryString.toInt.format.toCharArray] // DecimalFormat.format, but hover and linking shows Format.format
			.map[getItems(list, capacity)].filter[size > 0]
			.map[it -> map[value].reduce[v1, v2|v1 + v2]] // reduce[+]
			.sortBy[-value].map[key].head
    } 
    
    def private getItems(char[] binaryList, Iterable<Item> itemList, int capacity) {
    	val items = (0..binaryList.size-1).map[getItemForBinaryPosition(binaryList, itemList)].filter[it != null]
    	val sum = items.map[weight].reduce[w1, w2|w1 + w2] 	
    	if(sum != null && sum <= capacity) items else #[]
    }
    
    def private getItemForBinaryPosition(int index, char[] binaryList, Iterable<Item> itemList) {
    	val value = binaryList.get(index).toString
    	switch(value) { case "1": itemList.get(index)  default: null  }
    }
    
    def private toInt(String s) {  Integer.valueOf(s)  }
	
    def private operator_and(Iterable<Item> items1, Iterable<Item> items2) {
    	items1.toSet.union(items2.toSet)
    }	
    
    def private operator_power(int base, int exponent) {  base.pow(exponent)  }
}