## Last version: 20 February 2019

import check
from linked import *

print("Tests for Single")
single_first = Single("one")
single_second = Single("two")
single_third = Single("three")

print("Tests for store and access")
check.expect("Access first", single_first.access(), "one")
check.expect("Access second", single_second.access(), "two")
single_second.store("too")
check.expect("Access after mutation", single_second.access(), "too")

print("Tests for link and next")
check.expect("Null pointer", single_second.next(), None)
single_second.link(single_third)
check.expect("Next after link", single_second.next(), single_third)
single_first.link(single_second)

print("Tests for repr")
check.expect("Print first", repr(single_first), "Node containing one")
check.expect("Print second", repr(single_second), "Node containing too")

print("Tests for double")
double_first = Double("a")
double_second = Double("e")
double_third = Double("c")
double_last = Double("d")

print("Tests for store and access")
check.expect("Access first", double_first.access(), "a")
check.expect("Access second", double_second.access(), "e")
double_second.store("b")
check.expect("Access after mutation", double_second.access(), "b")

print("Tests for link_next, link_prev, next and prev")
check.expect("Null pointer for next", double_first.next(), None)
check.expect("Null pointer for prev", double_first.prev(), None)
double_first.link_next(double_second)
double_second.link_next(double_third)
double_third.link_next(double_last)

double_second.link_prev(double_first)
double_third.link_prev(double_second)
double_last.link_prev(double_third)
check.expect("Next pointer from first", double_first.next(), double_second)
check.expect("Previous pointer from last", double_last.prev(), double_third)

print("Tests for repr")
check.expect("Print first", repr(double_first), "Node containing a")
check.expect("Print last", repr(double_last), "Node containing d")

    
    
