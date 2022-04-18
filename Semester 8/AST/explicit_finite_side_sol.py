m = 5
n = 5
grid = [[0 for i in range(m)] for i in range(n)]
# Boundary Conditions

for i in range(n):
    grid[i][0] = 20
    grid[i][-1] = 20

for i in range(n):
    grid[0][i] = 40
    grid[-1][i] = 20



for i in range(1,m-1):
    for j in range(1,n-1):
        grid[i][j] = (grid[i-1][j]+grid[i+1][j]+grid[i][j-1]+grid[i][j+1])/4

for i in grid:
    print(*i)