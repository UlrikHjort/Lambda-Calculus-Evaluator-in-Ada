# Church numerals

# Zero - applies function 0 times
/f./x.x

# One - applies function 1 time
/f./x.f x

# Two - applies function 2 times
/f./x.f (f x)

# Three - applies function 3 times
/f./x.f (f (f x))

# Successor function
/n./f./x.f (n f x)

# Successor of 0 (should yield 1)
(/n./f./x.f (n f x)) (/f./x.x)

# Successor of 1 (should yield 2)
(/n./f./x.f (n f x)) (/f./x.f x)
