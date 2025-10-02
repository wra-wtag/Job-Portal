# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# frozen_string_literal: true

puts 'Cleaning database...'
Application.destroy_all
Bookmark.destroy_all
JobSkill.destroy_all
UserSkill.destroy_all
Job.destroy_all
RecruiterMembership.destroy_all
Company.destroy_all
Skill.destroy_all
User.destroy_all

puts 'Database cleaned.'
puts '----------------------------'

# Helper method for creating users
def create_user(first_name, last_name, email, password, role)
  User.find_or_create_by!(email: email) do |user|
    user.first_name = first_name
    user.last_name = last_name
    user.username = "#{first_name.downcase}.#{last_name.downcase}"
    user.password = password
    user.password_confirmation = password
    user.role = role
    user.confirmed_at = Time.current
    user.bio = "A passionate #{role.humanize.downcase}."
    user.location = 'Dhaka, Bangladesh'
  end
end

# 1. Create Users
puts 'Creating users...'

admin = create_user('Admin', 'User', 'admin@jobportal.com', 'password', 'admin')

recruiter_google = create_user('Sam', 'Wilson', 'sam.wilson@google.com', 'password', 'recruiter')
recruiter_microsoft = create_user('Maria', 'Hill', 'maria.hill@microsoft.com', 'password', 'recruiter')
recruiter_samsung = create_user('Nick', 'Fury', 'nick.fury@samsung.com', 'password', 'recruiter')
recruiter_welldev = create_user('Jane', 'Foster', 'jane.foster@welldev.io', 'password', 'recruiter')

job_seeker1 = create_user('Peter', 'Parker', 'peter.parker@example.com', 'password', 'job_seeker')
job_seeker2 = create_user('Wanda', 'Maximoff', 'wanda.maximoff@example.com', 'password', 'job_seeker')
job_seeker3 = create_user('Steve', 'Rogers', 'steve.rogers@example.com', 'password', 'job_seeker')

puts "#{User.count} users created."
puts '----------------------------'

# 2. Create Skills
puts 'Creating skills...'

SKILLS = {
  'Programming Language' => %w[Ruby Python JavaScript TypeScript Java Go C++],
  'Framework/Library' => [ 'Ruby on Rails', 'React', 'Node.js', 'Vue.js', 'Django', 'Spring Boot', 'Next.js' ],
  'Database' => %w[PostgreSQL MySQL MongoDB Redis Elasticsearch],
  'DevOps & Cloud' => %w[AWS Docker Kubernetes Terraform Jenkins Git CI/CD],
  'Specialized' => [ 'Machine Learning', 'Data Science', 'Natural Language Processing', 'GraphQL', 'System Design' ]
}.freeze

skills_map = {}
SKILLS.each do |category, names|
  names.each do |name|
    skill = Skill.find_or_create_by!(name: name, category: category)
    skills_map[name] = skill
  end
end

puts "#{Skill.count} skills created."
puts '----------------------------'

# 3. Create Companies & Recruiter Memberships
puts 'Creating companies and memberships...'

google = Company.find_or_create_by!(name: 'Google') do |c|
  c.description = 'A multinational technology company that specializes in Internet-related services and products.'
  c.location = 'Mountain View, CA, USA'
  c.website = 'https://careers.google.com'
  c.industry = 'Internet'
  c.size = '1000+'
end

microsoft = Company.find_or_create_by!(name: 'Microsoft') do |c|
  c.description = 'A multinational technology corporation which produces computer software, consumer electronics, personal computers, and related services.'
  c.location = 'Redmond, WA, USA'
  c.website = 'https://careers.microsoft.com'
  c.industry = 'Computer Software'
  c.size = '1000+'
end

samsung_rnd = Company.find_or_create_by!(name: 'Samsung R&D Institute Bangladesh') do |c|
  c.description = 'SRBD is a key research and development hub for Samsung Electronics, focusing on mobile software innovation.'
  c.location = 'Dhaka, Bangladesh'
  c.website = 'https://research.samsung.com/srbd'
  c.industry = 'Information Technology'
  c.size = '501-1000'
end

welldev = Company.find_or_create_by!(name: 'WellDev') do |c|
  c.description = 'A software development company providing high-quality, custom software solutions.'
  c.location = 'Dhaka, Bangladesh'
  c.website = 'https://welldev.io'
  c.industry = 'Information Technology and Services'
  c.size = '51-200'
end

[ google, microsoft, samsung_rnd, welldev ].each do |company|
  company.approve!(admin) unless company.approved?
end

RecruiterMembership.find_or_create_by!(user: recruiter_google, company: google, role: 'manager', is_primary: true)
RecruiterMembership.find_or_create_by!(user: recruiter_microsoft, company: microsoft, role: 'manager', is_primary: true)
RecruiterMembership.find_or_create_by!(user: recruiter_samsung, company: samsung_rnd, role: 'standard', is_primary: true)
RecruiterMembership.find_or_create_by!(user: recruiter_welldev, company: welldev, role: 'standard', is_primary: true)

puts "#{Company.count} companies and #{RecruiterMembership.count} memberships created."
puts '----------------------------'

# 4. Assign Skills to Job Seekers
puts 'Assigning skills to job seekers...'

UserSkill.find_or_create_by!(user: job_seeker1, skill: skills_map['JavaScript'], experience_years: 5)
UserSkill.find_or_create_by!(user: job_seeker1, skill: skills_map['React'], experience_years: 4)
UserSkill.find_or_create_by!(user: job_seeker1, skill: skills_map['Node.js'], experience_years: 3)

UserSkill.find_or_create_by!(user: job_seeker2, skill: skills_map['Python'], experience_years: 6)
UserSkill.find_or_create_by!(user: job_seeker2, skill: skills_map['Machine Learning'], experience_years: 4)
UserSkill.find_or_create_by!(user: job_seeker2, skill: skills_map['AWS'], experience_years: 3)

UserSkill.find_or_create_by!(user: job_seeker3, skill: skills_map['Ruby'], experience_years: 8)
UserSkill.find_or_create_by!(user: job_seeker3, skill: skills_map['Ruby on Rails'], experience_years: 7)
UserSkill.find_or_create_by!(user: job_seeker3, skill: skills_map['PostgreSQL'], experience_years: 6)
UserSkill.find_or_create_by!(user: job_seeker3, skill: skills_map['System Design'], experience_years: 5)

puts "#{UserSkill.count} user skills assigned."
puts '----------------------------'

# 5. Create Jobs & Assign Skills
puts 'Creating jobs and assigning skills...'

job1 = Job.find_or_create_by!(title: 'Senior Frontend Engineer (React)', company: google) do |job|
  job.posted_by_user = recruiter_google
  job.description = 'Join the Google Search team to build next-generation web applications...'
  job.employment_type = 'full_time'
  job.status = 'published'
  job.published_at = Time.current
  job.location = 'Mountain View, CA, USA'
  job.is_remote = true
  job.salary_min = 150_000
  job.salary_max = 220_000
  job.currency = 'USD'
  job.application_deadline = 1.month.from_now
end
job1.skills = [ skills_map['JavaScript'], skills_map['React'], skills_map['TypeScript'], skills_map['Next.js'] ]

job2 = Job.find_or_create_by!(title: 'Cloud DevOps Engineer', company: microsoft) do |job|
  job.posted_by_user = recruiter_microsoft
  job.description = 'Work on the Azure cloud platform to build and maintain scalable infrastructure...'
  job.employment_type = 'full_time'
  job.status = 'published'
  job.published_at = Time.current
  job.location = 'Redmond, WA, USA'
  job.salary_min = 140_000
  job.salary_max = 190_000
  job.currency = 'USD'
  job.application_deadline = 2.months.from_now
end
job2.skills = [ skills_map['AWS'], skills_map['Docker'], skills_map['Kubernetes'], skills_map['Terraform'], skills_map['CI/CD'] ]

job3 = Job.find_or_create_by!(title: 'Senior Software Engineer (Android)', company: samsung_rnd) do |job|
  job.posted_by_user = recruiter_samsung
  job.description = 'Develop innovative mobile applications for the Samsung Galaxy ecosystem...'
  job.employment_type = 'full_time'
  job.status = 'published'
  job.published_at = Time.current
  job.location = 'Dhaka, Bangladesh'
  job.salary_min = 2_400_000
  job.salary_max = 3_500_000
  job.currency = 'BDT'
  job.application_deadline = 3.weeks.from_now
end
job3.skills = [ skills_map['Java'], skills_map['C++'], skills_map['Git'] ]

job4 = Job.find_or_create_by!(title: 'Backend Engineer (Ruby on Rails)', company: welldev) do |job|
  job.posted_by_user = recruiter_welldev
  job.description = 'We are looking for a skilled Ruby on Rails developer...'
  job.employment_type = 'full_time'
  job.status = 'published'
  job.published_at = Time.current
  job.location = 'Dhaka, Bangladesh'
  job.salary_min = 1_800_000
  job.salary_max = 2_800_000
  job.currency = 'BDT'
  job.is_remote = true
  job.application_deadline = 1.month.from_now
end
job4.skills = [ skills_map['Ruby'], skills_map['Ruby on Rails'], skills_map['PostgreSQL'], skills_map['Redis'] ]

job5 = Job.find_or_create_by!(title: 'Machine Learning Engineer', company: google) do |job|
  job.posted_by_user = recruiter_google
  job.description = 'Work on Google\'s AI team to develop and deploy machine learning models at scale...'
  job.employment_type = 'full_time'
  job.status = 'published'
  job.published_at = Time.current
  job.location = 'Zurich, Switzerland'
  job.is_remote = false
  job.salary_min = 160_000
  job.salary_max = 240_000
  job.currency = 'USD'
  job.application_deadline = 2.months.from_now
end
job5.skills = [ skills_map['Python'], skills_map['Machine Learning'], skills_map['Data Science'], skills_map['AWS'] ]

puts "#{Job.count} jobs and #{JobSkill.count} job skills created."
puts '----------------------------'

# 6. Applications & Bookmarks
puts 'Creating applications and bookmarks...'

Application.find_or_create_by!(user: job_seeker1, job: job1) do |app|
  app.cover_letter = 'I am very excited about the Senior Frontend Engineer role at Google...'
  app.status = 'applied'
end

Application.find_or_create_by!(user: job_seeker2, job: job5) do |app|
  app.cover_letter = 'My experience in machine learning and data science makes me a strong candidate...'
  app.status = 'shortlisted'
end

Application.find_or_create_by!(user: job_seeker3, job: job4) do |app|
  app.cover_letter = 'As a seasoned Ruby on Rails developer, I am confident I can contribute to WellDev\'s success.'
  app.status = 'viewed'
end

Bookmark.find_or_create_by!(user: job_seeker1, job: job2)
Bookmark.find_or_create_by!(user: job_seeker3, job: job1)
Bookmark.find_or_create_by!(user: job_seeker3, job: job5)

puts "#{Application.count} applications and #{Bookmark.count} bookmarks created."
puts '----------------------------'

puts '✅ Seed data created successfully!'
