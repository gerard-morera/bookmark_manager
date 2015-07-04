feature 'User sign up' do

  before(:each) { @user = User.new user_params }

  def sign_up user
    visit '/users/new'
    expect(page.status_code).to eq(200)
    fill_in :email, with: user.email
    fill_in :password, with: user.password
    fill_in :password_confirmation, with: user.password_confirmation
    click_button 'Sign up'
  end

  scenario 'I can sign up as a new user' do
    expect { sign_up @user}.to change(User, :count).by(1)
    expect(page).to have_content('Welcome, alice@example.com')
    expect(User.first.email).to eq('alice@example.com')
  end


  scenario 'requires a matching confirmation password' do
    @user.password_confirmation = 'wrong'
    expect { sign_up @user }.not_to change(User, :count)
  end


  scenario 'with a password that does not match' do
    @user.password_confirmation = 'wrong'
    expect { sign_up @user }.not_to change(User, :count)
    expect(current_path).to eq('/users') # current_path is a helper provided by Capybara
    expect(page).to have_content 'Password and confirmation password do not match'
  end

  scenario 'user can not sign up without email' do
    @user.email = ""
    expect{sign_up @user }.not_to change(User, :count)
    expect(current_path).to eq('/users')
    expect(page).to have_content 'Email required'
  end

  scenario 'I cannot sign up with an existing email' do
    sign_up(@user)
    expect { sign_up(@user) }.to change(User, :count).by(0)
    expect(page).to have_content('Email taken')
  end

  def user_params
    { 
      email:                 'alice@example.com',
      password:              '12345678',
      password_confirmation: '12345678'
    }
  end

end
