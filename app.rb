#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

# инициализация базы данных
# создается переменная с БД и определяется параметр для возврата хеша

def init_db
	@db = SQLite3::Database.new 'lepra.db'
	@db.results_as_hash = true
end

# формирование сообщения об ошибке
# @error - переменная с текстом об ошибке, выводится в соответствующем вью
# получает хеш и проверяет если в нем есть пустой ключ то добавляется соотв значение

def set_error hh
  @error = hh.select { |key,_| params[key] == ''}.values.join(', ')
end

# выполнить прежде всего инициализацию БД

before do
	init_db
end

# конфигурация

configure do
	init_db

	# создать БД Посты если таковой не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS
		Posts
		(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			created_date DATE,
			content TEXT,
			autor TEXT
		);'

	# создать БД Комментариев если таковой не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS
		Comments
		(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			created_date DATE,
			content TEXT,
			post_id INTEGER
		);'
end

# обработка корневого запроса

get '/' do
	# сохранение в переменную текст базы данных Посты для вывода
	@result = @db.execute 'select * from posts order by id desc'
	erb :index
end

# новый пост
get '/new' do
	erb :new
end

#вывод информации о посте
get '/details/:post_id' do

	#получаем переменную из урла
	post_id = params[:post_id]

	#получаем список постов - у нас будет только один пост
	result = @db.execute 'select * from posts where id=?', [post_id]
	@row = result[0]

	#выбираем комментарии для нашего поста
	@comments = @db.execute 'select * from comments where post_id=?', [post_id]

	erb :details
end

# обработчик пост-запроса details - юзер отправляет комментарий к посту

post '/details/:post_id' do

	# получаем переменную номер поста из урл-а
	post_id = params[:post_id]

	# получаем содержание комментария
	content = params[:content]

	# добавляем в БД Комментариев эти переменные и дату написания
	@db.execute 'insert into comments (content, created_date, post_id)
		values (?,datetime(),?);', [content, post_id]

	# редирект на эту же страницу с новым комментарием
	redirect to ("/details/" + post_id)
end

# обработчик формы создания нового поста

post '/new' do

	# сохранение значений из формы в переменные - контент и автор
	@content = params[:content]
	@autor = params[:autor]

	# создание хэша для вызова функции по формированию отчета об ошибках
	hh = {:content => 'Введи текст поста', :autor => 'Представься'}
	set_error hh

	# если в переменной еррор что-то есть то выводим эту же страницу с сообщ об ошибках
	if @error != ''
		return erb :new
	end

	# добавляем в бд информацию о содержании поста, дате и авторе
	@db.execute 'insert into posts (content, created_date, autor)
		values (?,datetime(), ?);', [@content, @autor]

	# редирект на корневую страницу с новым постом
	redirect to '/'
end
