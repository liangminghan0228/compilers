#include<iostream>
#include<vector>
#include<stdio.h>
#include<cstdlib>
#include<stdlib.h>
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
        string type = "";
        bool istemp;//是否为临时变量
        bool isexpr = false;//是否为表达式类型的节点，表达式需要后序遍历来生成三地址码
        vector<Node*>children;
        Node(string key, int val)
        {
            this->val = val;
            this->key = key;
            istemp = false;
        }
        Node(string key, int val, int line, int col)
        {
            this->val = val;
            this->key = key;
            this->line = line;
            this->col = col;
            istemp = false;
        }        
        void addChild(Node* c)
        {
            this->children.push_back(c);
        }
};


