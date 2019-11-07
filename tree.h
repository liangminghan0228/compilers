#include<iostream>
#include<vector>
#include<stdio.h>
#include<cstdlib>
#include<iomanip>
#include<string>
#include<string.h>
#include<map>
#include <stdarg.h>
using namespace std;

class Node
{
    public:
        string key;
        int val;
        int count=0;
        vector<Node*>children;
        Node(string key, int val)
        {
            this->val = val;
            this->key = key;
        }        
        void addChild(Node* c)
        {
            this->children.push_back(c);
            this->count++;
        }

};

