# hur fan gör vi typer

## vad ska åstakommas

```python
def bar(foo: fn int, float → int) -> nil {
	print_int(foo(10, 50.1))
}

bar() a, b {
	print_float(b)
	return a * 2
}
```
blir i c++ (utan stdlib m.m.)
```cpp
# include <iostream>
# include <functional>

void bar(std::function<int(int, float)> foo) {
	// igentligen blir det här ett kall till print_int
	std::cout << foo(10, 50.1) << std::endl;
}

int main() {
	auto lambda = [&](int a, float b){
		// igentligen kall till print_float
		std::cout << std::to_string(b) << std::endl;
		return a * 2;
	};
	bar(lambda);
}
```

## hur gör vi detta
typens syntax är:
```
type : "fn" (type ("," type)*)? ("->"|"→") type |
       ... andra typer
```
lexern behövar altså lära sig "fn" och parsern behöver
lära sig det jag just skrev. codegen måste kunna skapa
funktion typer men det borde inte va något problem

syntax för funktions kall är nu:
```
call : value "(" args? ")" ((arg ("," arg)*)? "{" program "}")?
args : expr ("," expr)*
arg : IDENT ":" IDENT
```
förvirande, men inga nya tokens, jippi! sedan lägger vi till funktionen
som sista argument. för nu kommer det inte finnas något annat sätt att
skapa lamabdas även om det borde finnas det i framtiden. codegen för
funktioner måste lära sig skapa lambdas men det borde vara lätt (kanske,
men det liknar iaf hur vi skapar funktioner)

vår typ kod borde *kaaaanske* kunna hantera lambdas.

## en sista tanke
det skulle vara snyggare med
```
fn int, float int
```
kanske, men för nu har vi kvar pilen
fuck it vi kör utan pil _/('U')/C[]
