/*新建一个节点，并且将从下方传递来的节点加入其子结点*/
	void print(Node* p, int interval)
	{
		for(int i=0;i<interval;i++)
		{
			if(i<interval-2)
			{
				cout<<"| ";
			}
			else if(i==interval-2)
			{
				cout<<"|___>";
			}
			
		}
		cout<<p->key<<endl;
		for(int i=0;i<p->children.size();i++)
		{
			print(p->children[i], interval+1);
		}
	}
	void insertChildren(Node*par, ...)
	{
	    va_list list;
	    va_start(list,par);
	    Node *child;
		int count=0;
	    while(1)
	    {
	         count++;
			 child = va_arg(list, Node*);
			 if(child!=NULL)
			 {
				 if(child->key != "$")
				 	par->addChild(child);
				 else
				 	break;
			 }
			 else
				continue;			 
	     }
	     va_end(list);
	}
	bool returnError(Node*p, Node*root, bool isInt)//有语法错误返回true
	{
		//如果这个节点不为空且为return、
		if(p && p->key == "Return statement")
		{
			if(isInt)
			{
				cout<<"return error : need a return statement or expr after return at line "<<p->line<<" col "<<p->col<<endl;
				return true;
			}
			else
			{
				return false;
			}
		}
		else if(p && p->key == "Return expr statement")
		{
			if(isInt)
			{
				return false;
			}
			else
			{
				cout<<"return error : unexpected expr after return at line "<<p->line<<" col "<<p->col<<endl;
				return true;
			}
		}
		bool res = false;
		for(int i = 0; i < p->children.size(); i++)
		{
			int subres = returnError(p->children[i], root, isInt);
			res = res || subres;
		}
		//void返回递归得到的res,默认为没有语法错误
		if(!isInt)
		{
			return res;
		}
		else if(isInt && p == root)//在最外层的递归调用
		{
			bool resroot = true;//默认有语法错误
			for(int i = 0; i < p->children.size(); i++)
			{
				if(p->children[i]->key == "Return expr statement" || p->children[i]->key == "Return statement")
				{
					resroot = false;//有return语句就没有这个语法错误
				}
			}
			if(resroot)
			{
				cout<<"int main() need a return statement"<<endl;
				return true;
			}
		}
		return res;
	}