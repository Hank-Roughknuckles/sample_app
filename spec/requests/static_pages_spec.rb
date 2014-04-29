require 'spec_helper'

describe "Static pages" do

  subject { page }

  describe "Home page" do
    before { visit root_path }

    it { should have_content('Sample App') }
    it { should have_title(full_title('')) }
    it { should_not have_title('| Home') }

    describe "for signed-in users" do
      let!(:user) { FactoryGirl.create :user }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end

      describe "the sidebar" do
        let(:text) { "#{user.microposts.count} micropost" }

        it "should show the proper number of microposts in the sidebar" do
          expect(page).to have_selector("aside", text: text)
        end
      end

      describe "micropost pagination" do
        before(:all) { 31.times { FactoryGirl.create( :micropost, user: user )}}
        after(:all) { Micropost.delete_all }

        let!(:first_post) { Micropost.first }
        let!(:first_post) { Micropost.last }

        Micropost.paginate(page: 1).each do |micropost|
          expect(page).to have_selector('li', text: micropost.content)
        end
      end

      describe "micropost delete links" do
        let!(:other_user) { FactoryGirl.create(:user) }
        before { 
          visit root_path
          click_link "Sign out"
          sign_in other_user
          visit root_path
          print page.html
        }

        it "should not show delete links for microposts made by other
        users" do
          expect(page).not_to have_selector("delete")
        end
      end
    end
  end


  describe "Help page" do
    before { visit help_path }

    it { should have_content('Help') }
    it { should have_title(full_title('Help')) }
  end


  describe "About page" do
    before { visit about_path }

    it { should have_content('About Us') }
    it { should have_title(full_title('About Us')) }
  end


  describe "Contact page" do
    before { visit contact_path }

    it { should have_content('Contact') }
    it { should have_title(full_title('Contact')) }
  end

end
