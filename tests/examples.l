# Lambda Calculus Examples
# Lines starting with # are comments

# Identity function
/x.x

# Apply identity to variable y
(/x.x) y

# Constant function (returns first argument)
(/x./y.x) a b

# Church booleans
# True (select first)
(/x./y.x) a b

# False (select second)
(/x./y.y) a b

# Church numerals
# Zero
/f./x.x

# One
/f./x.f x

# Two
/f./x.f (f x)

# Successor function applied to 0 (produces 1)
(/n./f./x.f (n f x)) (/f./x.x)

# Self-application
(/x.x x) (/y.y)

# Omega combinator (non-terminating, limited by max steps)
(/x.x x) (/x.x x)
