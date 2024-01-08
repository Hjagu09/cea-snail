#if defined(__EMSCRIPTEN__)
#include <emscripten/bind.h>
#include <emscripten.h>
EM_JS(void, output, (char* x, int len_x), 
{
	const message = UTF8ToString(x, len_x);
	console.log(message);
	$('#history').append(message + '<br/>');
});

EM_JS(void, set_promt,(char* x, int len_x), 
{
	let message = UTF8ToString(x, len_x);
	message = message.replace(' ', '&nbsp;');
	$('#promt').html(message);
});
EM_JS(char*, input, (), 
{
	let jsString = input;
	let lengthBytes = lengthBytesUTF8(jsString) + 1;
	let stringOnWasmHeap = _malloc(lengthBytes);
	stringToUTF8(jsString, stringOnWasmHeap, lengthBytes);
	return stringOnWasmHeap;
});
EM_JS(bool, check_input, (), 
{
	return !((input?.trim()?.length || 0) > 0);
});
EM_JS(void, input_setup, (),
{
	  input = "";
});
#endif
