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

	# сохранение в переменную БД Посты для вывода
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

# обработчик пост-запроса details

post '/details/:post_id' do
	post_id = params[:post_id]
	content = params[:content]
	@db.execute 'insert into comments (content, created_date, post_id)
		values (?,datetime(),?);', [content, post_id]
	redirect to ("/details/" + post_id)
end

post '/new' do
	@content = params[:content]
	@autor = params[:autor]

	hh = {:content => 'Введи текст поста', :autor => 'Представься'}
	set_error hh

	if @error != ''
		return erb :new
	end

	@db.execute 'insert into posts (content, created_date, autor)
		values (?,datetime(), ?);', [@content, @autor]

	redirect to '/'
end
