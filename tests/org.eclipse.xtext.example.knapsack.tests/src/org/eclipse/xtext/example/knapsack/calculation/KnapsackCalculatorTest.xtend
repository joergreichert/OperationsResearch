package org.eclipse.xtext.example.knapsack.calculation

import com.google.inject.Inject
import org.eclipse.xtext.example.knapsack.KnapsackInjectorProvider
import org.eclipse.xtext.example.knapsack.knapsack.KnapsackProblem
import org.eclipse.xtext.example.knapsack.services.KnapsackGrammarAccess
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(KnapsackInjectorProvider))
class KnapsackCalculatorTest {
	@Inject extension ParseHelper<KnapsackProblem>
	@Inject extension KnapsackGrammarAccess grammarAccess
	@Inject extension KnapsackCalculator
	
	def private testDSL(String algorithm) '''
		algorithm: «algorithm»
		capacity: 30
		packed {
		}
		unpacked {
			"item 01" (weight=15, value=17),
			"item 02" (weight=05, value=08),
			"item 03" (weight=11, value=05),
			"item 04" (weight=05, value=09),
			"item 05" (weight=30, value=20),
			"item 06" (weight=08, value=05),
			"item 07" (weight=06, value=06),
			"item 08" (weight=12, value=10),
			"item 09" (weight=10, value=10),
			"item 10" (weight=15, value=20)
		}
	'''
	
	@Test
	def void testGreedy() {
		val model = testDSL(algorithmAccess.greedyGreedyKeyword_0_0.value).parse	
		val result = model.calculateOptimum
		assertEquals("expected item count", 3, result.size)
		assertEquals("expected first item name", "item 04", result.get(0).name)
		assertEquals("expected second item name", "item 02", result.get(1).name)
		assertEquals("expected third item name", "item 10", result.get(2).name)
		assertEquals("weight", 25, result.map[weight].reduce[w1, w2 | w1 + w2].intValue)
		assertEquals("value", 37, result.map[value].reduce[v1, v2 | v1 + v2].intValue)
	}	
	
	@Test
	def void testRecursion() {
		val model = testDSL(algorithmAccess.recursionRecursionKeyword_1_0.value).parse	
		val result = model.calculateOptimum
		assertEquals("expected item count", 3, result.size)
		assertEquals("expected first item name", "item 10", result.get(0).name)
		assertEquals("expected second item name", "item 09", result.get(1).name)
		assertEquals("expected third item name", "item 04", result.get(2).name)
		assertEquals("weight", 30, result.map[weight].reduce[w1, w2 | w1 + w2].intValue)
		assertEquals("value", 39, result.map[value].reduce[v1, v2 | v1 + v2].intValue)
	}	

	@Test
	def void testComplete() {
		val model = testDSL(algorithmAccess.completeCompleteKeyword_3_0.value).parse	
		val result = model.calculateOptimum
		assertNotNull("result shouldn't be null", result)
		assertEquals("expected item count", 3, result.size)
		assertEquals("expected first item name", "item 04", result.get(0).name)
		assertEquals("expected second item name", "item 09", result.get(1).name)
		assertEquals("expected third item name", "item 10", result.get(2).name)
		assertEquals("weight", 30, result.map[weight].reduce[w1, w2 | w1 + w2].intValue)
		assertEquals("value", 39, result.map[value].reduce[v1, v2 | v1 + v2].intValue)
	}	
}