#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'lepra.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS
		Posts
		(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			created_date DATE,
			content TEXT
		);'
	@db.execute 'CREATE TABLE IF NOT EXISTS
		Comments
		(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			created_date DATE,
			content TEXT,
			post_id INTEGER
		);'
end

get '/' do
	@result = @db.execute 'select * from posts order by id desc'
	erb :index
end

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
	content = params[:content]
	if content.strip.empty?
		@error = 'Да напишите уже что-нибудь!'
		return erb :new
	end

	@db.execute 'insert into posts (content, created_date)
		values (?,datetime());', [content]

	redirect to '/'
end
