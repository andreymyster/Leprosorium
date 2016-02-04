#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

# инициализация базы данных

set :database, "sqlite3:lepra_new.db"

# инициализация сущностей БД

class Post < ActiveRecord::Base
	has_many :comments, :foreign_key => "postID"
	validates :content, presence: true
	validates :author, presence: true
end

class Comment < ActiveRecord::Base
	belongs_to :post, :foreign_key => "postID"
	validates :content_com, presence: true
end

# обработка корневого запроса

get '/' do
	# сохранение в переменную текст базы данных Посты для вывода
	@result = Post.all
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

	#получаем список постов - у нас будет только один пост по этому номеру
	@result = Post.find post_id

	#выбираем комментарии для нашего поста
	# @comments = Comment.find_by post_id: post_id
	@comments = Comment.all

	erb :details
end

# обработчик пост-запроса details - юзер отправляет комментарий к посту

post '/details/:post_id' do

	# получаем содержание комментария и записываем в переменную бд
	c = Comment.new params[:comment]

	# добавляем в переменную номер поста из параметров урл-а
	c.post_id = params[:post_id]

	# сохраняем переменную в бд
	c.save!
	
	# редирект на эту же страницу с новым комментарием
	redirect to ("/details/" + post_id)
end

# обработчик формы создания нового поста

post '/new' do
	# сохранение значений из формы в переменную
	p = Post.new params[:post]
	p.save

	# редирект на корневую страницу с новым постом
	redirect to '/'
end
