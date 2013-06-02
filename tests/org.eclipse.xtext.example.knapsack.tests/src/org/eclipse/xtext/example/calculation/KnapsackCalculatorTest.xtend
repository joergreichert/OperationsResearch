package org.eclipse.xtext.example.calculation

import com.google.inject.Inject
import org.eclipse.xtext.example.KnapsackInjectorProvider
import org.eclipse.xtext.example.calculation.KnapsackCalculator
import org.eclipse.xtext.example.knapsack.KnapsackProblem
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
	@Inject extension KnapsackCalculator
	
	def private testDSL() '''
		algorithm: Greedy
		capacity: 10
		packed {
		}
		unpacked {
			"vase" (weight=3, value=50),
			"silver nugget" (weight=6, value=30),
			"painting" (weight=4, value=40),
			"mirror" (weight=5, value=10)
		}
	'''
	
	@Test
	def void test() {
		val model = testDSL.parse	
		val result = model.calculateOptimum
		assertEquals("expected item count", 2, result.size)
		assertEquals("expected first item name", "vase", result.get(0).name)
		assertEquals("expected second item name", "painting", result.get(1).name)
	}	
}