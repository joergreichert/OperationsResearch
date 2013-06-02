package org.eclipse.xtext.example.calculation

import com.google.common.collect.Sets
import java.text.DecimalFormat
import org.eclipse.xtext.example.knapsack.Algorithm
import org.eclipse.xtext.example.knapsack.Item
import org.eclipse.xtext.example.knapsack.KnapsackProblem
import org.eclipse.xtext.xbase.lib.Pair

class KnapsackCalculator {

    def calculateOptimum(KnapsackProblem it) {
    	packedItem.union(unpackedItem).calculateOptimum(algorithm, capacity)
    }
    
    def private calculateOptimum(Iterable<Item> it, Algorithm algorithm, int capacity) {
    	switch(algorithm) {
    		case Algorithm::RECURSION: 	calculateOptimumByRecusion(capacity)
    		case Algorithm::DP: 		calculateOptimumByDynamicProgramming(capacity)
    		default: 					calculateOptimumByGreedyAlgorithm(capacity)
    	}
    }
	
    def calculateOptimumByGreedyAlgorithm(Iterable<Item> it, int capacity) {
    	val list = it.toList
    	val count = size
    	val combinations = if(count == 0) 0 else Math::pow(2, count).intValue - 1
    	val formatter = new DecimalFormat((1..count).map["0"].join)
		val binaryLists = (0..combinations).map(value|formatter.format(Integer::valueOf(Integer::toBinaryString(value))).toCharArray())
		val optimumItemCompilation = binaryLists.map[getItems(list, capacity)].filter[size > 0]
			.map(itemList|new Pair(itemList, itemList.map[value].reduce[v1, v2|v1 + v2]))
			.sortBy[-value].map[key].head
		optimumItemCompilation	
    } 
    
    def private getItems(char[] binaryList, Iterable<Item> itemList, int capacity) {
    	val items = (0..binaryList.size-1).map(entry|entry.getItemForBinaryPosition(binaryList, itemList)).filter(item|item != null)
    	val sum = items.map[weight].reduce[w1, w2|w1 + w2] 	
    	if(sum != null && sum <= capacity) {
    		items
    	} else {
    		newArrayList
    	}
    }
    
    def private getItemForBinaryPosition(int index, char[] binaryList, Iterable<Item> itemList) {
    	val value = String::valueOf(binaryList.get(index))
    	switch(value) { case "1": {  itemList.get(index)  }  default: null}
    }
    
	def private calculateOptimumByRecusion(Iterable<Item> it, int capacity) {
		calculateOptimumByGreedyAlgorithm(capacity)
	}
	
	def private calculateOptimumByDynamicProgramming(Iterable<Item> it, int capacity) {
		calculateOptimumByGreedyAlgorithm(capacity)
	}
	
    def union(Iterable<Item> items1, Iterable<Item> items2) {
    	Sets::union(items1.toSet, items2.toSet)
    }	
}