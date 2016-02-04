#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

# инициализация базы данных

set :database, "sqlite3:lepra_new.db"

# инициализация сущностей БД

class Post < ActiveRecord::Base
	has_many :comments, :foreign_key => "articleID"
	validates :content, presence: true
	validates :author, presence: true
end

class Comment < ActiveRecord::Base
	belongs_to :post, :foreign_key => "articleID"
	validates :colcontent_com, presence: true
end

# обработка корневого запроса

get '/' do
	# сохранение в переменную текст базы данных Посты для вывода
	# @result = @db.execute 'select * from posts order by id desc'
	erb :index
end

# новый пост
get '/new' do
	erb :new
end

#вывод информации о посте
get '/details/:post_id' do

	# #получаем переменную из урла
	# post_id = params[:post_id]
	#
	# #получаем список постов - у нас будет только один пост
	# result = @db.execute 'select * from posts where id=?', [post_id]
	# @row = result[0]
	#
	# #выбираем комментарии для нашего поста
	# @comments = @db.execute 'select * from comments where post_id=?', [post_id]

	erb :details
end

# обработчик пост-запроса details - юзер отправляет комментарий к посту

post '/details/:post_id' do

	# получаем переменную номер поста из урл-а
	post_id = params[:post_id]

	# получаем содержание комментария
	content = params[:content]

	# добавляем в БД Комментариев эти переменные и дату написания
	# @db.execute 'insert into comments (content, created_date, post_id)
		# values (?,datetime(),?);', [content, post_id]

	# редирект на эту же страницу с новым комментарием
	redirect to ("/details/" + post_id)
end

# обработчик формы создания нового поста

post '/new' do

	# сохранение значений из формы в переменные - контент и автор
	@content = params[:content]
	@autor = params[:autor]


	# добавляем в бд информацию о содержании поста, дате и авторе
	# @db.execute 'insert into posts (content, created_date, autor)
	# 	values (?,datetime(), ?);', [@content, @autor]

	# редирект на корневую страницу с новым постом
	redirect to '/'
end
