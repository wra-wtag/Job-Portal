# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
admin = User.create!(
  email: 'admin@jobportal.com',
  password: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  username: 'admin',
  role: 'admin',
  email_verified: true,
  confirmed_at: Time.current
)

# Create Skills
programming_skills = [
  'Ruby', 'Python', 'JavaScript', 'Java', 'C++', 'PHP', 'Go', 'Swift'
]

framework_skills = [
  'Ruby on Rails', 'React', 'Vue.js', 'Angular', 'Django', 'Laravel', 'Spring Boot'
]

programming_skills.each do |skill_name|
  Skill.create!(name: skill_name, category: 'Programming')
end

framework_skills.each do |skill_name|
  Skill.create!(name: skill_name, category: 'Framework')
end

# Create Sample Companies
tech_company = Company.create!(
  name: 'TechCorp Solutions',
  slug: 'techcorp-solutions',
  description: 'Leading technology solutions provider',
  location: 'San Francisco, CA',
  website: 'https://techcorp.com',
  industry: 'Technology',
  size: '51-200',
  status: 'approved',
  approved_by: admin,
  approved_at: Time.current
)

# Create Sample Recruiter
recruiter = User.create!(
  email: 'recruiter@techcorp.com',
  password: 'password123',
  first_name: 'John',
  last_name: 'Recruiter',
  username: 'john_recruiter',
  role: 'recruiter',
  email_verified: true,
  confirmed_at: Time.current
)

# Create Recruiter Membership
RecruiterMembership.create!(
  user: recruiter,
  company: tech_company,
  role: 'manager',
  title: 'Senior Technical Recruiter',
  is_primary: true
)

# Create Sample Job Seeker
job_seeker = User.create!(
  email: 'jobseeker@example.com',
  password: 'password123',
  first_name: 'Jane',
  last_name: 'Developer',
  username: 'jane_developer',
  role: 'job_seeker',
  bio: 'Full-stack developer with 5 years experience',
  location: 'New York, NY',
  email_verified: true,
  confirmed_at: Time.current
)

puts "Seeded database with:"
puts "- 1 Admin user"
puts "- #{Skill.count} Skills"
puts "- 1 Company (approved)"
puts "- 1 Recruiter"
puts "- 1 Job Seeker"
