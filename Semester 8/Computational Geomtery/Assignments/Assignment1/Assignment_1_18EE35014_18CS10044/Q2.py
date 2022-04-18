# Using Python 3.7
import math
import random

num_points = 30

thetas = random.sample(range(0,360), num_points)
thetas.sort()
r = 100

points = [[int(r*math.cos((math.pi*thetas[i])/180)), int(r*math.sin((math.pi*thetas[i])/180))] for i in range(num_points)]

class Point:
    def __init__(self, x=None, y=None):
        self.x = x
        self.y = y
    
    def __add__(self, pt):
        x = self.x + pt.x
        y = self.y + pt.y
        return Point(x, y)
    
    def __sub__(self, pt):
        x = self.x - pt.x
        y = self.y - pt.y
        return Point(x, y)
    
    def cross(self, pt):
        return self.x*pt.y - self.y*pt.x
    
    def dot(self, pt):
        return self.x*pt.x + self.y*pt.y
    
    def orientation(self, pt1, pt2):
        # Orientation Test for points (self, pt1, pt2)
        return (pt1-self).cross((pt2-pt1))
    
    def __len__(self):
        return self.dot(self)
    
    def __str__(self):
        return "({} {})".format(self.x, self.y)

num_points = len(points)

# Converting points list having (x, y) to list of class Point
for i in range(num_points):
    points[i] = Point(points[i][0], points[i][1])

# Finding leftmost bottom point for the starting point
starting_point_ind = 0
for i in range(1, num_points):
    if((points[i].x<points[starting_point_ind].x) or (points[i].x==points[starting_point_ind].x and points[i].y<=points[starting_point_ind].y)):
        starting_point_ind = i
starting_point = points[starting_point_ind]

# Rotating left by starting_point_ind steps so that starting_point becomes first point in points
points = points[starting_point_ind:] + points[:starting_point_ind]

def sgn(val):
    if(val>0):
        return 1
    elif(val==0):
        return 0
    return -1

def isPointInsideTriangle(A, B, C, P):
    # If the query P lies inside the triangle then it must satisfy the below relation for unsigned area.
    # Area(triangle ABC) = Area(triangle APB) + Area(triangle BPC) + Area(triangle CPA)
    left_area = abs(A.orientation(B,C))
    right_area = abs(A.orientation(P,B)) + abs(B.orientation(P,C)) + abs(C.orientation(P,A))
    return right_area == left_area

def isPointInsideConvexPolygon(query):

    # Checking if the Query Point lies on left or right edge of starting_point
    if(starting_point.orientation(points[1], query)==0):
        return ((points[1]-starting_point).dot(query-starting_point)>=0) and (len(query-starting_point) <= len(points[1]-starting_point))

    if(starting_point.orientation(points[-1], query)==0):
        return ((points[-1]-starting_point).dot(query-starting_point)>=0) and (len(query-starting_point) <= len(points[-1]-starting_point))
    
    # Checking if the query point lies between the points just left and right side of the starting point
    # For the point to lie between the two points P_1 and P_{n-1}, orientation of P_{n-1} and Q must be same
    # for P_1 and same goes for P_{n-1} otherwise Q will lie outside.
    if(not (sgn(starting_point.orientation(points[1], query))==sgn(starting_point.orientation(points[1], points[-1])) and sgn(starting_point.orientation(points[-1], query))==sgn(starting_point.orientation(points[-1], points[1])))):
        return False

    pos = 0
    left = 0
    right = num_points - 1
    while(left<=right):
        mid = left + (right-left)//2
        if(starting_point.orientation(points[mid], query)>=0):
            # If the orientation of starting_point, curr_point and query is positive
            pos = mid
            left = mid + 1
        else:
            right = mid - 1
    
    # Check inside the triangle
    return isPointInsideTriangle(starting_point, points[pos], points[pos+1], query)

def save_svg(filename,query,result):
    # Determining the viewBox for the svg file
    min_x = float("inf")
    min_y = float("inf")
    max_x = float("-inf")
    max_y = float("-inf")
    for i in range(num_points):
        min_x = min(min_x, points[i].x)
        min_y = min(min_y, points[i].y)
        max_x = max(max_x, points[i].x)
        max_y = max(max_y, points[i].y)

    min_x = min(min_x, query.x)
    min_y = min(min_y, query.y)
    max_x = max(max_x, query.x)
    max_y = max(max_y, query.y)
    radius = 5

    file = open(filename, 'w')
    file.write("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"{} {} {} {}\">".format(min_x-3*r, min_y-3*r, (max_x-min_x)+5*r, (max_y-min_y)+5*r))

    # Drawing all the vertices
    for i in range(num_points):
            file.write("<circle cx=\""+ str(points[i].x) +"\" cy=\""+ str(points[i].y) +"\" r=\""+ str(radius) +"\" stroke=\"#000000\" stroke-width=\"0\" fill=\"#00ffff\" fill-opacity=\"1.0\" />")

    # Joining all the vertices
    for i in range(num_points-1):
        file.write("<line x1=\""+str(points[i].x)+"\" y1=\""+str(points[i].y)+"\" x2=\""+str(points[i+1].x)+"\" y2=\""+str(points[i+1].y)+"\" style=\"stroke:rgb(255,0,0);stroke-width:2\"/>")
    
    # Joining the starting point and last point
    file.write("<line x1=\""+str(points[0].x)+"\" y1=\""+str(points[0].y)+"\" x2=\""+str(points[num_points-1].x)+"\" y2=\""+str(points[num_points-1].y)+"\" style=\"stroke:rgb(255,0,0);stroke-width:2\"/>")
    
    # Drawing the query point
    file.write("<circle cx=\""+ str(query.x) +"\" cy=\""+ str(query.y) +"\" r=\""+ str(radius) +"\" stroke=\"#000000\" stroke-width=\"0\" fill=\"black\" fill-opacity=\"1.0\" />")

    # Displaying the result whether Inside or Outside
    file.write("<text x=\"0\" y=\"0\"> {} </text>".format(result))
    file.write("</svg>")
    file.close()

# Generating random query points and checking for them
for i in range(10):  
    query = [random.randint(-150,150), random.randint(-100,100)]
    # Converting query to Point Class form
    query = Point(query[0], query[1])
    filename = "fig_{}.svg".format(i)
    result = (isPointInsideConvexPolygon(query))
    if(result):
        result = "Inside"
    else:
        result = "Outside"
    save_svg(filename, query,result)
    print(result)

