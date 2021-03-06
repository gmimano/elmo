require 'spec_helper'

feature 'option suggestion dropdown' do
  before do
    @user = create(:user, role_name: 'coordinator')
    login(@user)
  end

  scenario 'creating, showing, and editing', js: true do
    click_link('Option Sets')

    # Fill in basic values
    click_link('Create New Option Set')
    fill_in('Name', with: 'Foo')
    check('Is Multilevel?')

    click_link('Add Level')
    wait_modal_to_be_visible
    fill_in('English', with: 'Typex')
    click_modal_save_button

    click_link('Add Level')
    wait_modal_to_be_visible
    fill_in('English', with: 'Species')
    click_modal_save_button

    find('#option_levels a.action_link_edit', match: :first).click # Click first pencil link.
    wait_modal_to_be_visible
    fill_in('English', with: 'Type') # Fix typo.
    click_modal_save_button

    # Go back to single level since dragging is hard here.
    2.times{ find('#option_levels a.action_link_remove', match: :first).click }
    uncheck('Is Multilevel?')

    add_options(%w(Banana Apple))

    click_button('Save')

    # Should redirect back to index page.
    expect(page).to have_selector('td.name_col a', text: 'Foo')

    # Test show mode (should have 'Apple' but no visible inputs or edit links).
    click_link('Foo')
    expect(page).to have_selector('#options-wrapper div', text: 'Banana')
    expect(page).to have_selector('#options-wrapper div', text: 'Apple')
    expect(page).not_to have_selector('form.option_set_form input[type=text]')
    expect(page).not_to have_selector('form.option_set_form a.action_link_edit')

    # Test edit mode (add another option)
    click_link('Edit Option Set')
    add_options(%w(Pear))
    click_button('Save')
    expect(page).to have_selector('td.options_col div', text: 'Banana, Apple, Pear')
  end

  scenario 'importing, editing, and showing standard', js: true do
    @std_set = create(:option_set, name: 'Gold', is_standard: true, multi_level: true)
    click_link('Option Sets')

    # Import
    click_link('Import Standard Option Sets')
    wait_modal_to_be_visible
    check('Gold')
    click_button('Import')
    wait_modal_to_hide
    wait_for_ajax
    expect(page).to have_selector('td.options_col div', text: 'Animal, Plant')

    # Editing standard set (edit option level name and option name)
    find("a.action_link_edit", match: :first).click
    all('#option-levels-wrapper a.action_link_edit')[1].click
    wait_modal_to_be_visible
    fill_in('English', with: 'Queendom')
    click_modal_save_button
    find('#options-wrapper ol ol a.action_link_edit', match: :first).click
    wait_modal_to_be_visible
    fill_in('English', with: 'Kitty')
    click_modal_save_button
    click_button('Save')

    # Show standard set to verify save worked.
    click_link('Gold')
    expect(page).to have_selector('#options-wrapper div.inner', text: 'Kitty')
  end

  scenario 'deleting' do
    os = create(:option_set, multi_level: true)
    visit(option_sets_path(mode: 'm', mission_name: os.mission.compact_name, locale: 'en'))
    find('a.action_link_destroy').click
    expect(page).to have_selector('.alert-success', text: 'Option Set deleted successfully')
  end

  def click_modal_save_button
    find('.modal-footer .btn-primary').click
    wait_modal_to_hide
  end

  def add_options(names)
    names.each do |name|
      fill_in_token_input("", with: name)
    end
    click_button('Add')
  end
end
