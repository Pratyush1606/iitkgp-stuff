file = open('fig1.svg', 'r')
data = file.read()
data = data.split("<")
points = []
for i in data:
    if("circle" in i):
        i1 = i.split()
        print(i1)
        x = i1[1]
        y = i1[2]
        x = int(x.split("=")[1].strip('"'))
        y = int(y.split("=")[1].strip('"'))
        points.append([x,y])
points = points[1:]
print(points)
file.close()

