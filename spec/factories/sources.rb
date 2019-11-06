# frozen_string_literal: true

FactoryBot.define do
  factory :source do
    filename { Faker::File.file_name }
    content { Faker::Lorem.paragraphs }
  end
end
