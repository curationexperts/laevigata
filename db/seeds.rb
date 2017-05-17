# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts
puts "== Removing any existing AdminSets  =="
puts "== Creating AdminSets and importing workflow =="
puts

require 'workflow_setup'
# Our database has just been reset, so you MUST destroy and
# re-create all AdminSets too
AdminSet.destroy_all
w = WorkflowSetup.new
w.schools.each do |school|
  w.make_mediated_deposit_admin_set(school)
end
