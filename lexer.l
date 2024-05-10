%{
    int charCounter=0;   
    int column =0,line=1;
    char right[1000][100000];
    char words[1000][100000];
    char error[1000][100000];
    int biaor=0;
    int biaoe=0;
    int flag=0;
    void addLine(int);
    void addColumn(int);
    void clearColumn();
    void addChar(int);
    void ShowError();
    void OutputData(const char *pFileName);
%}
digit                  [0-9]
int                    [0-9][0-9]*
semi                   [;]
comma                  [,]
assignop               [=]
reloop                 [>]|[<]|[>][=]|[<][=]|[=][=]|[!][=]
plus                   [+]
minus                  [-]
siar                   [*]
div                    [/]
mod                    [%]
yu                     [&]
huo                    [|]
yihuo                  [\^]
and                    [&][&]
or                     [|][|]
dot                    [.]
not                    [!]
leixing                "int"|"float"
return                 "return"
if                     "if"
else                   "else"
while                  "while"
reserveword            "break"|"main"|"continue"|"for"|"void"
operator               "#"
lp                     \(
rp                     \)
lb                     \[
rb                     \]
lc                     \{
rc                     \}
STRUCT                 "struct"
T 			           [ \t]+
id                     [a-zA-Z_][a-zA-Z_0-9]*

%%
{huo} {
    sprintf(right[biaor],"HUO");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{yu} {
    sprintf(right[biaor],"YU");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{yihuo} {
    sprintf(right[biaor],"YIHUO");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{mod} {
    sprintf(right[biaor],"MOD");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{return} {
    sprintf(right[biaor],"RETURN");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{if} {
    sprintf(right[biaor],"IF");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{else} {
    sprintf(right[biaor],"ELSE");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{while} {
    sprintf(right[biaor],"WHILE");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{reserveword} {
    sprintf(right[biaor],"reserveword");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{leixing} {
    sprintf(right[biaor],"TYPE");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{int} {
    sprintf(right[biaor],"INT_VALUE");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{semi} {
    sprintf(right[biaor],"SEMI");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{comma} {
    sprintf(right[biaor],"COMMA");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{assignop} {
    sprintf(right[biaor],"ASSIGNOP");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{reloop} {
    sprintf(right[biaor],"RELOP");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{plus} {
    sprintf(right[biaor],"PLUS");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{minus} {
    sprintf(right[biaor],"MINUS");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{siar} {
    sprintf(right[biaor],"STAR");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{div} {
    sprintf(right[biaor],"DIV");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{and} {
    sprintf(right[biaor],"AND");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{or} {
    sprintf(right[biaor],"OR");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{dot} {
    sprintf(right[biaor],"DOT");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{not} {
    sprintf(right[biaor],"NOT");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{lp} {
    sprintf(right[biaor],"LP");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{rp} {
    sprintf(right[biaor],"RP");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{lb} {
    sprintf(right[biaor],"LB");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{rb} {
    sprintf(right[biaor],"RB");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{lc} {
    sprintf(right[biaor],"LC");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{rc} {
    sprintf(right[biaor],"RC");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{STRUCT} {
    sprintf(right[biaor],"STRUCT");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{id} {
    sprintf(right[biaor],"ID");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}
{operator} {
    sprintf(right[biaor],"operator");
    sprintf(words[biaor],"%s",yytext);
    biaor++;
    addChar(yyleng);
}

{T}  {
}
. {
    addChar(1);
    addLine(1);
    ShowError();
}
\n      {
    addChar(1);
    addLine(1);
    clearColumn();
}
%%
int yywrap()    {
    return 1;
}

extern void OutputData(const char *pFileName)
{
    FILE * pFile;
	pFile = fopen(pFileName, "w");//这个用“w”是写文件，覆盖原内容，若不想覆盖则用“a”
	if (NULL == pFile)
	{//文件打开错误
		printf("error");
	}
	for (int i = 0; i < biaor; i++)
	{//循环输出数据并写入
		fprintf(pFile,"%s  %s\n", words[i], right[i]);//这里循环写入文件 3个  3.14
	}
	fclose(pFile);//最后一定记得关闭文件
}

void addLine(int cnt)   {
    line += cnt;
}
void addColumn(int cnt) {
    column += cnt;
}
void clearColumn()  {
    column = 0;
}
void addChar(int leng)  {
    charCounter += leng;
}
void ShowError()
{
  flag=1;     
  biaoe++;
}