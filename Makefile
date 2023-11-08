compile: setup.py
	python setup.py build_ext --inplace

test1: main.py imgs/newspaper.jpeg
	python main.py -i imgs/newspaper.jpeg

test2: main.py imgs/newspaper.jpeg
	python main.py -i imgs/newspaper.jpeg -p 200

test3: main.py imgs/monkey.webp
	python main.py -i imgs/monkey.webp

