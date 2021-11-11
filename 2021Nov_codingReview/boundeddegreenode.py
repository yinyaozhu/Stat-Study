class Node:
    """
    Fields: _degree contains the degree
            _links contains links to other nodes
            _attributes contains attributes 
    """

    ## Node(degree) produces a node of degree degree
    ##     storing an ID, a value, a weight, and a colour.
    ## __init__: Int -> Node
    ## Requires: degree >= 0
    def __init__(self, degree):
        self._degree = degree
        links = []
        for count in range(degree):
            links.append("nbr" + str(count))
        self._links = {}
        for link in links:
            self._links[link] = None
        attributes = ["ID", "value", "weight", "colour"]
        self._attributes = {}
        for attribute in attributes:
            self._attributes[attribute] = None

    ## print(self) prints attributes.
    ## Effects: Prints attributes.
    ## __str__: Node -> Str
    def __str__(self):
        to_print = ""
        for key in self._attributes:
            to_add = "Attribute " + str(key) + ": " \
                     + str(self._attributes[key]) + "\n"
            to_print = to_print + to_add
        return to_print

    ## self.degree() produces the degree of the node.
    ## degree: Node -> Int
    def degree(self):
        return self._degree
    
    ## self.access_link(link) produces the node, if any, linked
    ##     by link or None otherwise.
    ## access_link: Node Str -> (anyof Node None)
    ## Requires: link is of the form "nbrx" for 0 <= x < self.degree()
    def access_link(self, link):
        return self._links[link]

    ## self.access_attribute(attribute) produces the node, if any, stored
    ##     as attribute or None otherwise.
    ## access_attribute: Node Str -> (anyof Any None)
    ## Requires: attribute is one of "ID", "value", "weight", and "colour" 
    def access_attribute(self, attribute):
        return self._attributes[attribute]
    
    ## self.change_link(link, new) changes the given link to point to
    ##     new.
    ## Effect: Mutates self by changing a link.
    ## change_link: Node Str (anyof Node None) -> None
    ## Requires: link is of the form "nbrx" for 0 <= x < self.degree()
    def change_link(self, link, new):
        self._links[link] = new

    ## self.change_attribute(attribute, new) changes the given attribute to new.
    ## Effect: Mutates self by changing an attribute.
    ## change_attribute: Node Str Any -> None
    ## Requires: attribute is one of "ID", "value", "weight", and "colour" 
    def change_attribute(self, attribute, new):
        self._attributes[attribute] = new
        

