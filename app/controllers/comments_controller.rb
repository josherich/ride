# # coding: utf-8
# class CommentsController < ApplicationController
# 	before_filter :authenticate_user!
# 	before_filter :find_route_record

# 	def create
# 		@comment = @route_record.comments.build(params[:comment].merge(:user => current_user))
# 		if @comment.save
# 			flash[:notice] = "评论添加成功"
# 		else
# 			flash[:notice] = "添加失败"
# 		end
# 	end

# 	private

# 	def find_route_record
# 		@route_record = RouteRecord.find(params[:id])
# 	end
# end