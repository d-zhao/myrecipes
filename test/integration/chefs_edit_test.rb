require 'test_helper'

class ChefsEditTest < ActionDispatch::IntegrationTest
  def setup
    @chef = Chef.create!(chefname: "Delmar", email: "delmar@example.com",
                            password: "password", password_confirmation: "password")
    @chef2 = Chef.create!(chefname: "john", email: "john@example.com",
                            password: "password", password_confirmation: "password")
    @admin_user = Chef.create!(chefname: "john", email: "admin@example.com",
                            password: "password", password_confirmation: "password", admin: true)
  end

  test "reject an invalid edit" do
    sign_in_as(@chef, "password")
    get edit_chef_path(@chef)
    assert_template 'chefs/edit'
    patch chef_path(@chef), params: { chef: { chefname: " ", email: "delmar.quatchi@gmail.com"} }
    assert_template 'chefs/edit'
    assert_select 'h2.panel-title'
    assert_select 'div.panel-body'
  end

  test "accept a valid edit" do 
    sign_in_as(@chef, "password")
    get edit_chef_path(@chef)
    assert_template 'chefs/edit'
    patch chef_path(@chef), params: { chef: { chefname: "DelmarZ", email: "delmar.example@gmail.com"} }
    assert_redirected_to @chef
    assert_not flash.empty?
    @chef.reload
    assert_match "DelmarZ", @chef.chefname
    assert_match "delmar.example@gmail.com", @chef.email
  end

  test "accept edit attempt by admin user" do
    sign_in_as(@admin_user, "password")
    get edit_chef_path(@chef)
    assert_template 'chefs/edit'
    patch chef_path(@chef), params: { chef: { chefname: "Delmar4", email: "delmar4.example@gmail.com"} }
    assert_redirected_to @chef
    assert_not flash.empty?
    @chef.reload
    assert_match "Delmar4", @chef.chefname
    assert_match "delmar4.example@gmail.com", @chef.email
  end

  test "redirect edit attempt by non-admin user" do
    sign_in_as(@chef2, "password")
    updated_name = "joe"
    updated_email = "joe@email.com"
    patch chef_path(@chef), params: { chef: { chefname: updated_name, email: updated_email} }
    assert_redirected_to chefs_path
    assert_not flash.empty?
    @chef.reload
    assert_match "Delmar", @chef.chefname
    assert_match "delmar@example.com", @chef.email
  end
end
