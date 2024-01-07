void EXPOSE(print)(std::string str)
{
	std::cout << str << std::endl;
}

void EXPOSE(for)(int low, int high, std::function<void(int)> action)
{
	for (int i = low; i < high; i++)
	{
		action(i);
	}
}
