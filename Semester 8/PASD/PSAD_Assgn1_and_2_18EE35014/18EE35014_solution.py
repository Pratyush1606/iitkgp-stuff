'''
PSAD Assignment 1
Submitted By:
Pratyush Jaiswal
18EE35014
'''
# Using Python 3.7
from collections import defaultdict, deque
from matplotlib import pyplot as plt
import cmath
import math
from pathlib import Path
import sys
import os

ANSWER_FILE = Path("./18EE35014_answer.txt") # For storing network data
PLOT_DIR = Path("./18EE35014_PLOTS") # For storing the plots

# Making Plots forlder if didn't exist
if not os.path.exists(PLOT_DIR):
    os.mkdir(PLOT_DIR)

# Making a blank answer file
with open(ANSWER_FILE, "w") as f:
    f.write("")

class Node:
    '''
    Class for every nodes consisting of required attributes
    '''
    def __init__(self, node_id=None, current=None, voltage=None, load=None, parent=None):
        self.node_id = node_id
        self.current = current
        self.voltage = voltage
        self.load = load
        self.parent = parent
    
class Branch:
    '''
    Class for every branches connecting two nodes consisting of required attributes
    '''
    def __init__(self, branch_id=None, sending_node=None, receiving_node=None, impedance=None, current=None):
        self.branch_id = branch_id
        self.sending_node = sending_node
        self.receiving_node = receiving_node
        self.impedance = impedance
        self.current = current 

class Network:
    '''
    Class consisting of all nodes, branches and methods required for the analysis
    '''
    def __init__(self, data, nb, base_mva, base_kv):
        self.nb = nb                                        # Number of base nodes
        self.base_mva = base_mva                            # Base MVA
        self.base_kv = base_kv                              # Base voltage in kV
        self.base_z = (self.base_kv**2)/self.base_mva       # Base imepdance
        self.base_ka = self.base_mva/self.base_kv           # Base Current
        self.network = defaultdict(list)                    # Map for storing the network 
        self.node_map = defaultdict(lambda: None)           # Map for getting node object with node id
        self.branch_map = defaultdict(list)                 # Map for getting branch object with branch id
        self.node_branch_map = defaultdict(lambda: None)    # Map for getting branch object from rec and sending nodes ids
        for i in range(len(data)):
            u, v, r, x, p, q = data[i]
            # Taking Node Ids in int format
            u = int(u)
            v = int(v)
            # If the node is not saved then a node is made and being mapped to the corresponding Node Id
            if(not self.node_map[u]):
                self.node_map[u] = Node(node_id=u, current=None, voltage=1+0j, load=None, parent=None)
            if(not self.node_map[v]):
                self.node_map[v] = Node(node_id=v, current=None, voltage=1+0j, load=(p+q*1j)/(1000*self.base_mva), parent=self.node_map[u])
            
            # Setting load of the receiving load
            if(not self.node_map[v].load):
                self.node_map[v].load = (p+q*1j)/(1000*self.base_mva)
            
            # Saving the branch with sending and receiving end nodes and mapping the branch to the Branch Id
            self.branch_map[i+1] = Branch(branch_id=i+1, sending_node=self.node_map[u], receiving_node=self.node_map[v], impedance=(r+x*1j)/self.base_z, current=None)
            # Saving the adjacency list assuming directed flow between sending and receiving end
            self.network[u].append(v)
            # Maping branch with sendind and receiving node ids to retrieve the branch easily
            self.node_branch_map[(u,v)] = self.branch_map[i+1]
        
        # Making the hierarchy of the Network
        self.make_hierarchy()
        
    def make_hierarchy(self):
        '''
        Function making the hierarchies from top (source) to bottom (leaf)
        '''
        '''
        Here a breadth first search (bfs) is implemented starting from top to leaf.
        Since this is a directed tree, storing edges and nodes on every step of the bfs will 
        result in all nodes and branches sorted topologically (meaning parents will appear before 
        their children.

        node_hierarchy: A list consisiting of all nodes topologically sorted manner
        branch_hierarchy: A list consisiting of all branches topologically sorted manner

        For example, if the network is like:
        1 -(1)- 2 -(2)- 3 -(3)- 4 -(4)- 5
                |       |
               (5)     (6)
                |       |
                |       9 -(9)- 10
                |       
                6 -(7) 7 -(8)- 8
        Then the list can be like something this:
        node_hierarchy: 1, 2, 6, 7, 8, 3, 4, 5, 9, 10
        branch_hierarchy: (1), (5), (7), (8), (2), (3), (4), (6), (9)
        
        Here it can be seen that the child nodes are appearing after the parent nodes
        and some goes for the branches based on the connecting nodes

        There is a computational reason for using this hierarchy. While updating any branch data, 
        we will have to itertate through every nodes in the subtree of the node if we store subtree
        which will take O(n^2) computation compelxity. But if we use this concept of topological sort 
        then we can reduce the computation complexity to O(n*k) where k is the maximum number of branch
        connected to a node.
        '''
        self.node_hierarchy = []
        self.branch_hierarchy = []
        q = deque([1])
        while(q):
            curr_node_id = q.popleft()
            self.node_hierarchy.append(self.node_map[curr_node_id])
            for child_id in self.network[curr_node_id]:
                self.branch_hierarchy.append(self.node_branch_map[(curr_node_id, child_id)])
                q.append(child_id)

    def compute_node_currents(self):
        '''
        Function computing all the node currents

        Relation being used here:
        I(load current) = (P-Qj)/(V*) = (conjugate of Load Power)/(conjugate of Voltage)
        '''
        for node in self.node_hierarchy:
            if(node.node_id==1):
                # Slack Bus (not a load node)
                continue
            node.current = node.load.conjugate() / node.voltage.conjugate()
    
    def compute_branch_currents(self):
        '''
        Function for calculating branch currents from leaf nodes to top nodes
        '''
        '''
        Here branch current can be calculated by adding up the receiving end node current and 
        all the currents of the branches from the receiving end node. And this should be done 
        from leaf to source such that before updating the parent side, children side should be 
        updated.

        For example if the branch looks like:
        1 - 2 - 3
            |
            4
        The current in branch between 1 and 2 is equal to the sum of the currents in node 2 
        and the currents in the branches (2 - 4) and (2 - 3). So we can see here currents in 
        branches (2 - 4) and (2 - 3) should be updated before this branch (1 - 2) being updated.
        '''
        for branch in self.branch_hierarchy[::-1]:
            receiving_node = branch.receiving_node
            branch.current = receiving_node.current
            for child_node_id in self.network[receiving_node.node_id]:
                branch.current += self.node_branch_map[(receiving_node.node_id, child_node_id)].current
            
    def compute_node_voltages(self):
        '''
        Function for updating node voltages from top nodes to leaf nodes
        
        Here the nodes voltage should be updated from parent to leaf, that is why node hierarchy 
        is being used
        '''
        for node in self.node_hierarchy:
            if(node.node_id==1):
                continue
            parent_node = node.parent
            branch = self.node_branch_map[(parent_node.node_id, node.node_id)]
            node.voltage = parent_node.voltage - branch.current*branch.impedance
    
    def compute_power_loss(self):
        '''
        Function for computing power loss in branches
        
        Relation being used here:
        loss = Sum of (|branch_current|*|branch_current|*(Branch Impedance)) for all branches 
        Loss will be a complex number consisting both real and reactive power loss
        '''
        loss = 0
        for branch in self.branch_hierarchy:
            curr_magnitude = abs(branch.current)
            loss += (curr_magnitude*curr_magnitude)*branch.impedance
        return loss
    
    def get_solution(self):
        '''
        Function for computing the solution using the convergence criteria
        
        Convergence Criteria being used:
        When |P_loss(k+1) - P_loss(k)| < epsilon and |Q_loss(k+1) - Q_loss(k)| < epsilon
        then solution has converged.
        '''
        epsilon = 0.00001 # Epsilon paramter for convergence
        # Initialising starting conditions (first itertaion)
        self.compute_node_currents()
        self.compute_branch_currents()
        self.compute_node_voltages()
        curr_loss = self.compute_power_loss()
        delta_loss = curr_loss
        # If it is the first iteration then ignore the convergence checking criteria and go for next itertaion
        first_iteration = True 
        while(first_iteration or (not (abs(delta_loss.real) < epsilon and abs(delta_loss.imag) < epsilon))):
            first_iteration = False
            self.compute_node_currents()
            self.compute_branch_currents()
            self.compute_node_voltages()
            last_loss = curr_loss
            curr_loss = self.compute_power_loss() # Current Loss
            delta_loss =  curr_loss - last_loss # Calculating the current difference
    
    def reset(self):
        '''
        Function for resetting the nodes and branches current and voltage values to the original one
        '''
        for node in self.node_hierarchy:
            node.current = None
            node.voltage = 1+0j
        for branch in self.branch_hierarchy:
            branch.current = None
    
    def compute_J(self, w1, w2, P_loss_0, sum_Vi_0_sq):
        '''
        Function for computing J quantity based on the relation:
        J = w1*(P_loss_dg/P_loss_0) + w2*((sum of square of Vi_dg for all nodes)/(sum of square of Vi_0 for all nodes))

        Since P_loss_0 and sum_Vi_0_sq are going to be constant everytime for this function, 
        those are precalculated and used everytime
        '''
        sum_Vi_dg_sq = 0 # For getting sum of square of Vi_dg for all nodes
        for node_id in range(2, self.nb+1):
            node = self.node_map[node_id] # Retrieving node from node_id
            sum_Vi_dg_sq += (abs(node.voltage)-1)**2 
        P_loss_dg = self.compute_power_loss().real # Getting the real part of the current power loss (P_loss_dg)
        return w1*(P_loss_dg/P_loss_0) + w2*(sum_Vi_dg_sq/sum_Vi_0_sq)
    
    def compute_plot_data_J_vs_P_dg(self, w1, w2, node_id_to_be_changed, P_loss_0, sum_Vi_0_sq):
        '''
        Function for computing the J plotting data for a specific network, w1, w2, P_loss_0 and sum_Vi_0_sq
        
        node_id_to_be_changed: Node Id of the node whose real load power has to be changed
        P_loss_0: Real power loss when there is no decrease in the power load at the specific node
        sum_Vi_0_sq: sum of square of Vi_0 for all nodes
        '''
        # Keeping the original load power of the node whose data has to be changed to update to the 
        # original data after this plotting data has been prepared 
        orig_load = self.node_map[node_id_to_be_changed].load
        x_data = [] # For storing the potting x data 
        y_data = [] # For storing the potting y data 
        for i in range(0, 25000, 25):
            # Resetting for getting the solution from the starting condition
            self.reset()
            # Changing the node load step by step
            self.node_map[node_id_to_be_changed].load -= i/(1000*self.base_mva)
            # After changing the load, getting the solution
            self.get_solution()
            # Storing the x data which is basically P_dg 
            x_data.append(i)
            # Storing the computed J value for y axis
            y_data.append(self.compute_J(w1=w1, w2=w2, P_loss_0=P_loss_0, sum_Vi_0_sq=sum_Vi_0_sq))
            # Reupdating the node data to original one
            self.node_map[node_id_to_be_changed].load = orig_load
        return x_data, y_data
    
    def plot_J_vs_P_dg(self):
        '''
        Function for pllotting J vs P_dg plot for given network
        '''
        # Getting the starting solutions for initial conditions
        self.reset()
        self.get_solution()
        # Computing and storing the P_loss_0 which will be used everytime for calculating J
        P_loss_0 = self.compute_power_loss().real
        # Computing and storing the sum_Vi_o_ssq which will be used everytime for calculating J
        sum_Vi_0_sq = 0
        for node_id in range(2, self.nb+1):
            node = self.node_map[node_id]
            sum_Vi_0_sq += (abs(node.voltage)-1)**2
        
        node_to_be_changed = 6      # Storing which Node Id's power has to be changed fot plotting J
        if(self.nb==10):
            # If network is the 10 nodes one then Node 6 will be changed
            node_to_be_changed = 6
            
        elif(self.nb==33):
            # If network is the 33 nodes one then Node 7 will be changed
            node_to_be_changed = 7

        # Looping and plotting for two pair values for w1 and w2 and from (0.1 to 0.9)
        for w1, w2 in [(x*0.1, 1 - 0.1*x) for x in range(0, 11)]:
            w1 = round(w1, 1)
            w2 = round(w2, 1)
            x_data, y_data = self.compute_plot_data_J_vs_P_dg(w1, w2, node_to_be_changed, P_loss_0, sum_Vi_0_sq)
            plt.plot(x_data, y_data)
            plt.title(f"NB: {self.nb}, w1: {w1}, w2: {w2}")
            plt.xlabel("P_dg (in kW)")
            plt.ylabel("J")
            # Saving the plot
            file_name = f"fig_NB_{self.nb}_w1_{w1}_w2_{w2}.png"
            file_location = os.path.join(PLOT_DIR, file_name)
            plt.savefig(file_location)
            # Showing the plot
            # plt.show()  
            plt.close()
    
    def get_angle_abs(self, vector):
        '''
        Returns absolute value of a vector and corresponding angle in degrees
        '''
        vec_len, vec_angle = cmath.polar(vector)
        vec_angle = math.degrees(vec_angle)
        return vec_len, vec_angle

    def show_network(self):
        print(f"NB: {self.nb}")
        node_data = [[] for i in range(self.nb+1)]
        for node in self.node_hierarchy[::-1]:
            for child_node_id in self.network[node.node_id]:
                node_data[node.node_id] += [child_node_id] + node_data[child_node_id]

        print("Printing nodes and corresponding subtree")
        for node_id in range(1, self.nb+1):
            node = self.node_map[node_id]
            print("{}:  {}".format(node_id, node_data[node_id]))

        print()
        print()

        print("Printing Nodal Data")
        for node_id in range(2, self.nb+1):
            node = self.node_map[node_id]
            print("Node_Id: {}".format(node_id))
            pu_voltage, voltage_ang = self.get_angle_abs(node.voltage)
            pu_current, current_ang = self.get_angle_abs(node.current)
            print(f"Voltage: {pu_voltage:.5f}∠{voltage_ang:.4f}°pu = {pu_voltage*self.base_kv:.5f}∠{voltage_ang:.4f}°kV")
            print(f"Current: {pu_current:.5f}∠{current_ang:.4f}°pu = {pu_current*self.base_ka:.5f}∠{current_ang:.4f}°kA")
            print(f"Active Power: {node.load.real:.5f}pu = {node.load.real*self.base_mva*1000:.5f}kW") 
            print(f"Reactive Power: {node.load.imag:.5f}pu = {node.load.imag*self.base_mva*1000:.5f}kVAR")
            print()
           
        print()

        print("Printing Branch Data")
        for branch in self.branch_hierarchy:
            print("Branch_Id: {} from {} to {}".format(branch.branch_id, branch.sending_node.node_id, branch.receiving_node.node_id))
            pu_current, current_ang = self.get_angle_abs(branch.current)
            print(f"Current: {pu_current:.5f}∠{current_ang:.4f}°pu = {pu_current*self.base_ka:.5f}∠{current_ang:.4f}°kA")
            print()
           
        print()

        print("Printing Power Loss")
        loss = self.compute_power_loss()
        print(f"Active Power Loss: {loss.real:.5f}pu = {loss.real*self.base_mva*1000:.5f}kW") 
        print(f"Reactive Power Loss: {loss.imag:.5f}pu = {loss.imag*self.base_mva*1000:.5f}kVAR")

        print()
        print()
    
    def get_solution_based_on_alpha(self):
        '''
        Function for computing the solution using the convergence criteria
        
        Convergence Criteria being used:
        When |P_loss(k+1) - P_loss(k)| < epsilon and |Q_loss(k+1) - Q_loss(k)| < epsilon
        then solution has converged.
        '''
        epsilon = 0.00001 # Epsilon paramter for convergence
        # Initialising starting conditions (first itertaion)
        self.compute_node_currents()
        self.compute_branch_currents()
        self.compute_node_voltages()
        curr_loss = self.compute_power_loss()
        delta_loss = curr_loss
        # If it is the first iteration then ignore the convergence checking criteria and go for next itertaion
        first_iteration = True 
        while(first_iteration or (not (abs(delta_loss.real) < epsilon and abs(delta_loss.imag) < epsilon))):
            first_iteration = False
            self.compute_node_currents()
            self.compute_branch_currents()
            self.compute_node_voltages()
            for node_id in range(2, self.nb+1):
                curr_node = self.node_map[node_id]
                if(curr_node.voltage.real<0):
                    return 
            last_loss = curr_loss
            curr_loss = self.compute_power_loss() # Current Loss
            delta_loss =  curr_loss - last_loss # Calculating the current difference

    def get_iterations_num_based_on_alpha(self):
        '''
        Function to get the number of iterations based on increasing alpha
        '''
        # Resetting the network to the original data
        curr_alpha = 0.05
        iter_count = 0
        check = True
        while(check):
            self.reset()
            iter_count += 1
            for node_id in range(2, self.nb+1):
                curr_node = self.node_map[node_id]
                curr_node.load = curr_node.load*(1+iter_count*curr_alpha)
            self.get_solution_based_on_alpha()
            for node_id in range(2, self.nb+1):
                curr_node = self.node_map[node_id]
                if(curr_node.voltage.real<0):
                    check = False
                    break
            if(iter_count>100):
                print("Not converging")
                break
            for node_id in range(2, self.nb+1):
                curr_node = self.node_map[node_id]
                curr_node.load = curr_node.load/(1+iter_count*curr_alpha)
        print(f"# For {self.nb} nodes network")
        print(f"The number of iterations for which the solution is feasible is {iter_count-1}")
        print(f"On {iter_count} iteration, the solution will not be feasible")
        print(f"Considering the value of alpha for the first iteration equal to {curr_alpha},")
        print(f"The value of alpha till which the solution is feasible: {(iter_count-1)*curr_alpha}")
        print()

def main(data, nb, base_mva, base_kv):
    # Extracting data from data string
    data = data.split("\n")
    data = [data[i].strip().split() for i in range(len(data)) if i!=len(data)-1]
    for i in range(len(data)):
        for j in range(len(data[i])):
            data[i][j] = float(data[i][j])
    network = Network(data=data, nb=nb, base_mva=base_mva, base_kv=base_kv)
    # Getting the solution
    network.get_solution()
    # Printing the network data after the solution has converged
    network.show_network()
    # Plotting J vs P_dg graphs for different w1 and w2
    network.plot_J_vs_P_dg()
    # For Assignment 4
    network.get_iterations_num_based_on_alpha()

    

class Tee(object):
    '''
    Class for displaying on terminal as well as saving to the file
    '''
    def __init__(self, *files):
        self.files = files
    def write(self, obj):
        for f in self.files:
            f.write(obj)
    def flush(self):
        pass

if __name__ == "__main__":
    # Configuring script to print to stdout as well as answer.txt
    f = open(ANSWER_FILE, 'a', encoding='utf-8')
    backup = sys.stdout
    sys.stdout = Tee(sys.stdout, f)

    # First Case
    data = '''1	2	0.0922	0.0470	100	60	
    2	3	0.4930	0.2511	90	40	
    3	4	0.3660	0.1864	120	80	
    4	5	0.3811	0.1941	60	30	
    5	6	0.8190	0.7070	60	20	
    6	7	0.1872	0.6188	200	100	
    7	8	0.7114	0.2351	200	100	
    8	9	1.0300	0.7400	60	20	
    9	10	1.0440	0.7400	60	20	
    10	11	0.1966	0.0650	45	30	
    11	12	0.3744	0.1238	60	35	
    12	13	1.4680	1.1550	60	35	
    13	14	0.5416	0.7129	120	80	
    14	15	0.5910	0.5260	60	10	
    15	16	0.7463	0.5450	60	20	
    16	17	1.2890	1.7210	60	20	
    17	18	0.7320	0.5740	90	40	
    2	19	0.1640	0.1565	90	40	
    19	20	1.5042	1.3554	90	40	
    20	21	0.4095	0.4784	90	40	
    21	22	0.7089	0.9373	90	40	
    3	23	0.4512	0.3083	90	50	
    23	24	0.8980	0.7091	420	200	
    24	25	0.8960	0.7011	420	200	
    6	26	0.2030	0.1034	60	25	
    26	27	0.2842	0.1447	60	25	
    27	28	1.0590	0.9337	60	20	
    28	29	0.8042	0.7006	120	70	
    29	30	0.5075	0.2585	200	600	
    30	31	0.9744	0.9630	150	70	
    31	32	0.3105	0.3619	210	100	
    32	33	0.3410	0.5302	60	40	
    '''
    base_mva = 10
    base_kv = 12.66
    nb = 33
    main(data, nb, base_mva, base_kv)

    # Second Case
    data = '''1   2	0.1233	0.4127	1840    460	
        2	3	0.0140	0.6051  980     340	
        3	4	0.7463	1.2050	1790    446	
        4	5	0.6984	0.6084	1598	1840	
        5	6	1.9831	1.7276	1610	600	
        6	7	0.9053	0.7886	780	    110	
        7	8	2.0552	1.1640	1150	60	
        8	9	4.7953	2.7160	980     130	
        9	10	5.3434	3.0264	1640	200	
    '''
    base_mva = 10
    base_kv = 23
    nb = 10
    main(data, nb, base_mva, base_kv)
