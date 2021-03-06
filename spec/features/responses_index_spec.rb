require 'spec_helper'

feature 'responses index' do
  before do
    @user = create(:user)
    @form = create(:form, name: 'TheForm')
  end

  scenario 'returning to index after response loaded via ajax', js: true, sphinx: true do
    login(@user)
    click_link('Responses')
    expect(page).not_to have_content('TheForm')

    # Create response and make it show up via AJAX
    create(:response, form: @form)
    page.execute_script('responses_fetch();')
    expect(page).to have_content('TheForm')

    # Click response and then go back. Should still be there!
    click_link(Response.first.id.to_s)
    click_link('Responses')
    expect(page).to have_content('TheForm')
  end
end
