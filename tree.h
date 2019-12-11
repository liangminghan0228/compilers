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
        int line = 0;
        int col = 0;
        vector<Node*>children;
        Node(string key, int val)
        {
            this->val = val;
            this->key = key;
        }
        Node(string key, int val, int line, int col)
        {
            this->val = val;
            this->key = key;
            this->line = line;
            this->col = col;
        }        
        void addChild(Node* c)
        {
            this->children.push_back(c);
        }

};

