//
//  Blog.swift
//  
//
//  Created by Tyler Thompson on 4/9/22.
//

import Plot
import Publish

@available(macOS 12.0, *)
struct Blog: SitePageProtocol {
    let context: PublishingContext<APrincipalEngineer>
    let section: Section<APrincipalEngineer>

    var html: HTML {
        SitePage(sitePage: section,
                 context: context) {
            ComponentGroup(html: #"""
               <!-- Page Title
               ================================================== -->
               <div id="page-title">

                  <div class="row">

                     <div class="ten columns centered text-center">
                        <h1>Our Blog<span>.</span></h1>

                        <p>Aenean condimentum, lacus sit amet luctus lobortis, dolores et quas molestias excepturi
                        enim tellus ultrices elit, amet consequat enim elit noneas sit amet luctu. </p>
                     </div>

                  </div>

               </div> <!-- Page Title End-->

               <!-- Content
               ================================================== -->
               <div class="content-outer">

                  <div id="page-content" class="row">

                     <div id="primary" class="eight columns">

                        <article class="post">

                           <div class="entry-header cf">

                              <h1><a href="single.html" title="">Proin gravida nibh vel velit auctor aliquet Aenean sollicitudin auctor.</a></h1>

                              <p class="post-meta">

                                 <time class="date" datetime="2014-01-14T11:24">Jan 14, 2014</time>
                                 /
                                 <span class="categories">
                                 <a href="#">Design</a> /
                                 <a href="#">User Inferface</a> /
                                 <a href="#">Web Design</a>
                                 </span>

                              </p>

                           </div>

                           <div class="post-thumb">
                              <a href="single.html" title=""><img src="images/post-image/post-image-1300x500-01.jpg" alt="post-image" title="post-image"></a>
                           </div>

                           <div class="post-content">

                              <p>Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum auctor,
                              nisi elit consequat ipsum, nec sagittis sem nibh id elit. Duis sed odio sit amet nibh vulputate
                              cursus a sit amet mauris. Morbi accumsan ipsum velit. Nam nec tellus a odio tincidunt auctor a
                              ornare odio. Sed non  mauris vitae erat consequat auctor eu in elit. </p>

                           </div>

                        </article> <!-- post end -->

                        <article class="post">

                           <div class="entry-header cf">

                              <h1><a href="single.html" title="">Proin gravida nibh vel velit auctor aliquet Aenean sollicitudin auctor.</a></h1>

                              <p class="post-meta">

                                 <time class="date" datetime="2014-01-14T11:24">Jan 14, 2013</time>
                                 /
                                 <span class="categories">
                                 <a href="#">Design</a> /
                                 <a href="#">User Inferface</a> /
                                 <a href="#">Web Design</a>
                                 </span>

                              </p>

                           </div>

                           <div class="post-thumb">
                              <a href="single.html" title=""><img src="images/post-image/post-image-1300x500-02.jpg" alt="post-image" title="post-image"></a>
                           </div>

                           <div class="post-content">

                              <p>Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum auctor,
                              nisi elit consequat ipsum, nec sagittis sem nibh id elit. Duis sed odio sit amet nibh vulputate
                              cursus a sit amet mauris. Morbi accumsan ipsum velit. Nam nec tellus a odio tincidunt auctor a
                              ornare odio. Sed non  mauris vitae erat consequat auctor eu in elit. </p>

                           </div>

                        </article> <!-- post end -->

                        <article class="post">

                           <div class="entry-header cf">

                              <h1><a href="single.html" title="">Proin gravida nibh vel velit auctor aliquet Aenean sollicitudin auctor.</a></h1>

                              <p class="post-meta">

                                 <time class="date" datetime="2014-01-14T11:24">Jan 14, 2014</time>
                                 /
                                 <span class="categories">
                                 <a href="#">Design</a> /
                                 <a href="#">User Inferface</a> /
                                 <a href="#">Web Design</a>
                                 </span>

                              </p>

                           </div>

                           <div class="post-thumb">
                              <a href="single.html" title=""><img src="images/post-image/post-image-1300x500-03.jpg" alt="post-image" title="post-image"></a>
                           </div>

                           <div class="post-content">

                              <p>Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum auctor,
                              nisi elit consequat ipsum, nec sagittis sem nibh id elit. Duis sed odio sit amet nibh vulputate
                              cursus a sit amet mauris. Morbi accumsan ipsum velit. Nam nec tellus a odio tincidunt auctor a
                              ornare odio. Sed non  mauris vitae erat consequat auctor eu in elit. </p>

                           </div>

                        </article> <!-- post end -->

                        <!-- Pagination -->
                        <nav class="col full pagination">
                                <ul>
                              <li><span class="page-numbers prev inactive">Prev</span></li>
                                    <li><span class="page-numbers current">1</span></li>
                                    <li><a href="#" class="page-numbers">2</a></li>
                              <li><a href="#" class="page-numbers">3</a></li>
                              <li><a href="#" class="page-numbers">4</a></li>
                              <li><a href="#" class="page-numbers">5</a></li>
                              <li><a href="#" class="page-numbers">6</a></li>
                              <li><a href="#" class="page-numbers">7</a></li>
                              <li><a href="#" class="page-numbers">8</a></li>
                              <li><a href="#" class="page-numbers">9</a></li>
                                    <li><a href="#" class="page-numbers next">Next</a></li>
                                </ul>
                            </nav>

                     </div> <!-- Primary End-->

                     <div id="secondary" class="four columns end">

                        <aside id="sidebar">

                           <div class="widget widget_search">
                              <h5>Search</h5>
                              <form action="#">

                                 <input class="text-search" type="text" onfocus="if (this.value == 'Search here...') { this.value = ''; }" onblur="if(this.value == '') { this.value = 'Search here...'; }" value="Search here...">
                                 <input type="submit" class="submit-search" value="">

                              </form>
                           </div>

                           <div class="widget widget_text">
                              <h5 class="widget-title">Text Widget</h5>
                              <div class="textwidget">Proin gravida nibh vel velit auctor aliquet.
                              Aenean sollicitudin, lorem quis bibendum auctor, nisi elit consequat ipsum,
                              nec sagittis sem nibh id elit. Duis sed odio sit amet nibh vulputate cursus
                              a sit amet mauris. Morbi accumsan ipsum velit. </div>
                             </div>

                           <div class="widget widget_categories">
                              <h5 class="widget-title">Categories</h5>
                              <ul class="link-list cf">
                                 <li><a href="#">Designs</a></li>
                                 <li><a href="#">Internet</a></li>
                                 <li><a href="#">Typography</a></li>
                                 <li><a href="#">Photography</a></li>
                                 <li><a href="#">Web Development</a></li>
                                 <li><a href="#">Projects</a></li>
                                 <li><a href="#">Other Stuff</a></li>
                              </ul>
                           </div>

                           <div class="widget widget_tag_cloud">
                              <h5 class="widget-title">Tags</h5>
                              <div class="tagcloud cf">
                                 <a href="#">drupal</a>
                                 <a href="#">joomla</a>
                                 <a href="#">ghost</a>
                                 <a href="#">wordpress</a>
                              </div>
                           </div>

                           <div class="widget widget_photostream">
                              <h5>Photostream</h5>
                              <ul class="photostream cf">
                                 <li><a href="#"><img src="images/thumb.jpg" alt="thumbnail"></a></li>
                                 <li><a href="#"><img src="images/thumb.jpg" alt="thumbnail"></a></li>
                                 <li><a href="#"><img src="images/thumb.jpg" alt="thumbnail"></a></li>
                                 <li><a href="#"><img src="images/thumb.jpg" alt="thumbnail"></a></li>
                                 <li><a href="#"><img src="images/thumb.jpg" alt="thumbnail"></a></li>
                                 <li><a href="#"><img src="images/thumb.jpg" alt="thumbnail"></a></li>
                                 <li><a href="#"><img src="images/thumb.jpg" alt="thumbnail"></a></li>
                                 <li><a href="#"><img src="images/thumb.jpg" alt="thumbnail"></a></li>
                              </ul>
                            </div>

                        </aside>

                     </div> <!-- Secondary End-->

                  </div>

               </div> <!-- Content End-->
            """#)
        }.html
    }
}
