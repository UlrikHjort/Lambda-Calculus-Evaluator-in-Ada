# Combinators

# I combinator (identity)
/x.x

# K combinator (constant)
/x./y.x

# S combinator
/x./y./z.x z (y z)

# Apply K to two arguments
(/x./y.x) a b

# Self-application
/x.x x

# Apply self-application to identity
(/x.x x) (/y.y)

# Omega combinator (non-terminating, limited to max steps)
(/x.x x) (/x.x x)
