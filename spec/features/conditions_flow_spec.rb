require 'spec_helper'

feature 'conditions flow', js: true do
  before do
    @user = create(:user)
    @form = create(:form, name: 'Foo', question_types: %w(multi_level_select_one integer text))
    login(@user)
    visit(edit_form_path(@form, locale: 'en', mode: 'm', mission_name: get_mission.compact_name))
    expect(page).to have_content('Edit Form')
  end

  scenario 'add and update condition to existing question' do
    question_code = @form.questions[0].code

    all('a.action_link.edit')[1].click
    select_question_and_wait_to_populate_other_selects(1, question_code)
    select('is equal to', from: 'Comparison')
    select('Animal', from: 'Kingdom')
    click_button('Save')

    # View the questioning and ensure the condition is shown correctly.
    visit("/en/m/#{@form.mission.compact_name}/questionings/#{@form.questionings[1].id}")
    expect(page).to have_content("Question #1 #{question_code}
      Kingdom is equal to \"Animal\"")

    # Update the condition to have a full option path.
    visit("/en/m/#{@form.mission.compact_name}/forms/#{@form.id}/edit")
    all('a.action_link.edit')[1].click
    select('Dog', from: 'Species')
    click_button('Save')

    # View and test again.
    visit("/en/m/#{@form.mission.compact_name}/questionings/#{@form.questionings[1].id}")
    expect(page).to have_content("Question #1 #{question_code}
      Species is equal to \"Dog\"")
  end

  scenario 'add a new question with a condition' do
    question_code = @form.questions[0].code

    click_link('Add Questions')
    fill_in('Code', with: 'NewQ')
    select('Text', from: 'Type')
    fill_in('Title (English)', with: 'New Question')
    select_question_and_wait_to_populate_other_selects(1, question_code)
    select('is equal to', from: 'Comparison')
    select('Plant', from: 'Kingdom')
    select('Oak', from: 'Species')
    click_button('Save')

    # Check the new condition
    visit("/en/m/#{@form.mission.compact_name}/questionings/#{@form.reload.questionings[3].id}")
    expect(page).to have_content("Question #1 #{question_code}
      Species is equal to \"Oak\"")
  end

  scenario 'add a condition referring to an integer question' do
    question_code = @form.questions[1].code

    all('a.action_link.edit')[2].click
    select_question_and_wait_to_populate_other_selects(2, question_code)
    select('is less than', from: 'Comparison')
    fill_in('Value', with: '5')
    click_button('Save')

    # View the questioning and ensure the condition is shown correctly.
    visit("/en/m/#{@form.mission.compact_name}/questionings/#{@form.questionings[2].id}")
    expect(page).to have_content("Question #2 #{question_code} is less than 5")
  end

  def select_question_and_wait_to_populate_other_selects(counter, question_code)
    select(question_label(counter, question_code), from: 'Question')
    wait_for_ajax
  end

  def question_label(counter, question_code)
    "#{counter}. #{question_code}"
  end
end
