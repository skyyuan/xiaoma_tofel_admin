# encoding: utf-8
class AdminsController < ApplicationController

  def index
    @admins = Admin.order("created_at desc").page(params[:page])
  end

  def new
    @admin = Admin.new
  end

  def create_admin
    admin = Admin.new(params[:admins])
    if admin.save
      redirect_to admins_path
    else
      errors = []
      if admin.errors.messages.present?
        admin.errors.full_messages.each do |error|
          errors << "*" + error
        end
        flash[:errors] = errors #admin.errors.full_messages.join(", ") + '<br>'
      end
      redirect_to new_admin_path
    end

  end

  def edit
    @admin = Admin.find params[:id]
  end

  def update_admin
    errors = []
    @admin = Admin.find params[:id]
    @admin.username = params[:admins][:username]
    @admin.role = params[:admins][:role]
    @admin.email = params[:admins][:email]

    if params[:admins][:password].present?
      if params[:admins][:password] == params[:admins][:password_confirmation]
        @admin.password = params[:admins][:password]
      else
        errors << "*Password confirmation doesn't match Password"
      end
    end

    if errors.present?
      flash[:errors] = errors
      redirect_to edit_admin_path(@admin.id)
    else
      if @admin.save
        redirect_to admins_path
      else
        if @admin.errors.messages.present?
          @admin.errors.full_messages.each do |error|
            errors << "*" + error
          end
          flash[:errors] = errors
        end
        redirect_to edit_admin_path(@admin.id)
      end
    end
  end

  def destroy
    @admin = Admin.find(params[:id])
    @admin.destroy
    redirect_to admins_path
  end
end
