# dictionary

myDictionary = { 1:'John', 2:'Bob', 3:'Alice'}

class human:
    name = None
    age = None
    def get_name(self):
        print("Enter your name")
        self.name=input()
    def get_age(self):
        print("Enter your age")
        self.age=input()
    def put_name(self):
        print("Your name is",self.name)
