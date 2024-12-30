# Using Python 3.7
import random
from functools import cmp_to_key
import matplotlib.pyplot as plt

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
        return (pt1-self).cross(pt2-pt1)
    
    def __len__(self):
        return self.dot(self)
    
    def __str__(self):
        return "{} {}".format(self.x, self.y)

min_x = 0
min_y = 0

max_x = 2000
max_y = 2000

num_points = 30

x_coords = random.sample(range(min_x, max_x), num_points)
y_coords = random.sample(range(min_y, max_y), num_points)
points = [[x_coords[i], y_coords[i]] for i in range(num_points)]

# Converting points list having (x, y) to list of class Point
for i in range(num_points):
    points[i] = Point(points[i][0], points[i][1])

# Finding leftmost bottom point for the starting point
starting_point_ind = 0
for i in range(1, num_points):
    if((points[i].x<points[starting_point_ind].x) or (points[i].x==points[starting_point_ind].x and points[i].y<=points[starting_point_ind].y)):
        starting_point_ind = i

starting_point = points[starting_point_ind]

def cmp_orientation(point1, point2):
    # Comparing function for the orientation of (starting point, point1, point2)

    # Point1 will be joined before Point2 if the orientation comes out to be CCW (CounterClockWise)
    # else Point2 will be preffered to Point1
    # If the orientation comes out to be zero then the nearest point will be joined first
    orientation = starting_point.orientation(point1, point2)
    if(orientation==0):
        return len(point1-starting_point) - len(point2-starting_point)
    return -orientation

# Eliminating Starting Point from the list and sorting based on the orientation
polar_coords = [points[i] for i in range(num_points) if i!=starting_point_ind]
polar_coords.sort(key=cmp_to_key(cmp_orientation))

# Inserting starting point at the end and starting for joining the last point to the starting point to close the polygon
polar_coords.append(points[starting_point_ind])
polar_coords = [points[starting_point_ind]] + polar_coords

plt.figure()
plt.plot([x.x for x in polar_coords], [x.y for x in polar_coords])
# Joining the points
for i in range(len(polar_coords)-1):
    plt.scatter([polar_coords[i].x, polar_coords[i+1].x], [polar_coords[i].y, polar_coords[i+1].y])

# Showing the plot
plt.show()
