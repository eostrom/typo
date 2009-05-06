require File.dirname(__FILE__) + '/../spec_helper'

# These are integration tests. They are not comprehensive. If you're
# hacking on the converter, please add tests first.

describe "WordPress 2.5 converter" do
  before :each do
    # Fixtures aren't being rolled back in the WP DB, so we delete them all before
    # each test. This is a simple hack, but slows things down.
    [WP25::Option, WP25::User, WP25::Post, WP25::Comment].each do |model_class|
      model_class.delete_all
    end
    
    Factory('WP25/option',
      :option_name => 'blogname', :option_value => 'My WordPress Blog')
    Factory('WP25/option',
      :option_name => 'blogdescription', :option_value => 'WordPress blog description')
  end
  
  it "runs without crashing" do
    run_converter
  end
  
  describe "given a user" do
    before :each do
      @poster = Factory('WP25/user',
        :display_name => 'A. User',
        :user_email => 'auser@notfound.com',
        :user_login => 'auser',
        :user_pass => 'not a valid password'
      )
    end
    
    it "creates a user" do
      lambda { run_converter }.should change(User, :count).by(1)
    end

    describe "and a post" do
      before :each do
        # TODO: figure out if we're handling GMT conversion correctly
        @post = Factory('WP25/post',
          :post_title => 'A Post',
          :post_excerpt => '',
          :post_content => 'I got something to say!',
          :post_author => @poster.ID
        )
      end
      
      it "creates an article" do
        lambda { run_converter }.should change(Article, :count).by(1)
      end
      
      it "assigns the article's author" do
        run_converter
        Article.find(:first, :order => 'created_at DESC').user.login.should ==
          @poster.user_login
      end
      
      describe "with a comment" do
        before :each do
          @comment = Factory('WP25/comment',
            :comment_post_ID => @post.ID,
            :comment_author => 'Anonymous Commenter'
          )
        end
        
        it "creates a comment" do
          lambda { run_converter }.should change(Comment, :count).by(1)
        end
        
        it "assigns the comment's author"
            
        describe "that is spam" do
          it "marks the created comment as spam"
        end
      end
      
      describe "given tags and categories" do
        it "behaves in a manner to be determined"
      end 
    end
    
    describe "and a page" do
      it "creates a page"
    end
  end
  
  protected
  
  def run_converter(options = {})
    real_stdout = $stdout
    begin
      $stdout = StringIO.new unless options[:verbose]
      TypoPlugins.convert_from :wp25
    ensure
      $stdout = real_stdout
    end
  end
end
