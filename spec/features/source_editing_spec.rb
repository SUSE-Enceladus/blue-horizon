# frozen_string_literal: true

require 'rails_helper'

describe 'source editing', type: :feature do
  let!(:sources) { populate_sources }

  it 'lists all sources' do
    visit('/sources')
    sources.each do |source|
      expect(page).to have_content(source.filename)
    end
  end

  it 'edits sources' do
    source = sources.sample
    random_content = Faker::Lorem.paragraph
    expect(source.content).not_to eq(random_content)
    visit('/sources')

    click_on(source.filename)
    fill_in_hidden('#source_content', random_content)
    click_on(id: 'submit-source')

    expect(page).to have_content('Source was successfully updated.')
    source.reload
    expect(source.content).to eq(random_content)
  end

  it 'creates new sources' do
    random_content = Faker::Lorem.paragraph
    filename = Faker::File.file_name
    visit('/sources')

    click_on('New Source')
    fill_in('source[filename]', with: filename)
    click_on(id: 'submit-source')
    expect(page).to have_content('Source was successfully created.')
    fill_in_hidden('#source_content', random_content)
    click_on(id: 'submit-source')
    expect(page).to have_content('Source was successfully updated.')

    source = Source.last
    expect(source).to be_a(Source)
    expect(filename).to include(source.filename)
    expect(source.content).to eq(random_content)
  end

  it 'deletes sources' do
    source = create(:source)
    visit('/sources')

    click_on(source.filename)
    click_on 'Delete'
    expect(page).to have_content('Source was successfully destroyed.')

    expect { Source.find(source.id) }.to raise_exception(ActiveRecord::RecordNotFound)
  end

  private

  # the textarea is "hidden behind" the JS editor
  def fill_in_hidden(findable, content)
    first(findable, visible: false).set(content)
  end
end
