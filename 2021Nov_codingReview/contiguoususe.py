## Last version: 13 June 2019
import check
from contiguous import *

three_array = Contiguous(3)
five_array = Contiguous(5)

print("Tests for size")
check.expect("Size three", three_array.size(), 3)
check.expect("Size five", five_array.size(), 5)

five_array.store(0, "zero")
five_array.store(1, "one")
five_array.store(3, "three")
five_array.store(4, "four")

print("Tests for access and store")
check.expect("Access 3", five_array.access(3), "three")
check.expect("Access 4", five_array.access(4), "four")
check.expect("Access 2", five_array.access(2), None)

five_array.store(4, "fore")

check.expect("Mutate 4", five_array.access(4), "fore")

print("Tests for repr")
check.expect("Print three", repr(three_array), "(None,None,None)")
check.expect("Print five", repr(five_array), "(zero,one,None,three,fore)")

array_one = Contiguous(5)
array_one.store(0, 0)
array_one.store(1, 1)
array_one.store(2, 2)
array_one.store(3, 3)
array_one.store(4, 4)

array_two = Contiguous(5)
array_two.store(0, 0)
array_two.store(1, 1)
array_two.store(2, 2)
array_two.store(3, 3)
array_two.store(4, 5)

print("Tests for equality")
check.expect("Same equal", array_one == array_one, True)
check.expect("Not equal", array_one == array_two, False)

array_two.store(4, 4)

check.expect("Modified to be equal", array_one == array_two, True)

print("Tests for inequality")
check.expect("Same equal", array_one != array_one, False)
check.expect("Different equal", array_one != array_two, False)

array_two.store(4, 10)

check.expect("Modified to not be equal", array_one != array_two, True)
