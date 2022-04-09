//
//  About.swift
//  
//
//  Created by Tyler Thompson on 4/9/22.
//

import Plot
import Publish

@available(macOS 12.0, *)
struct About: SitePageProtocol {
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
                           <h1>About Us<span>.</span></h1>

                           <p>Aenean condimentum, lacus sit amet luctus lobortis, dolores et quas molestias excepturi
                           enim tellus ultrices elit, amet consequat enim elit noneas sit amet luctu. </p>
                        </div>

                     </div>

                  </div> <!-- Page Title End-->

                  <!-- Content
                  ================================================== -->
                  <div class="content-outer">

                     <div id="page-content" class="row page">

                        <div id="primary" class="eight columns">

                           <section>

                              <h1>Meet our talented team.</h1>

                              <p class="lead">Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum auctor,
                              nisi elit consequat ipsum, nec sagittis sem nibh id elit. Duis sed odio sit amet nibh vulputate
                              cursus a sit amet mauris. Morbi accumsan ipsum velit. </p>

                              <p>Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum auctor,
                              nisi elit consequat ipsum, nec sagittis sem nibh id elit. Duis sed odio sit amet nibh vulputate
                              cursus a sit amet mauris. Morbi accumsan ipsum velit. Nam nec tellus a odio tincidunt auctor a
                              ornare odio. Sed non  mauris vitae erat consequat auctor eu in elit. </p>

                              <div class="row">

                                 <div id="team-wrapper" class="bgrid-halves cf">

                                    <div class="column member">

                                       <img src="images/team/team-img-01.jpg" alt=""/>

                                       <div class"member-name">
                                          <h5>Naruto Uzumaki</h5>
                                          <span>Creative Director</span>
                                       </div>

                                       <p>Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum auctor,
                                         nisi elit consequat ipsum, nec sagittis sem nibh id elit. </p>

                                       <ul class="member-social">
                                          <li><a href="#"><i class="fa fa-facebook"></i></a></li>
                                          <li><a href="#"><i class="fa fa-twitter"></i></a></li>
                                          <li><a href="#"><i class="fa fa-google-plus"></i></a></li>
                                          <li><a href="#"><i class="fa fa-linkedin"></i></a></li>
                                          <li><a href="#"><i class="fa fa-skype"></i></a></li>
                                       </ul>

                                       </div>

                                    <div class="column member">

                                       <img src="images/team/team-img-02.jpg" alt=""/>

                                       <div class"member-name">
                                          <h5>Sakura Haruno</h5>
                                          <span>Lead Creative</span>
                                       </div>

                                       <p>Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum auctor,
                                         nisi elit consequat ipsum, nec sagittis sem nibh id elit. </p>

                                       <ul class="member-social">
                                          <li><a href="#"><i class="fa fa-facebook"></i></a></li>
                                          <li><a href="#"><i class="fa fa-twitter"></i></a></li>
                                          <li><a href="#"><i class="fa fa-google-plus"></i></a></li>
                                          <li><a href="#"><i class="fa fa-linkedin"></i></a></li>
                                          <li><a href="#"><i class="fa fa-skype"></i></a></li>
                                       </ul>

                                       </div>

                                    <div class="column member">

                                       <img src="images/team/team-img-03.jpg" alt=""/>

                                       <div class"member-name">
                                          <h5>Sasuke Uchiha</h5>
                                          <span>Lead Web Designer</span>
                                       </div>

                                       <p>Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum auctor,
                                         nisi elit consequat ipsum, nec sagittis sem nibh id elit. </p>

                                       <ul class="member-social">
                                          <li><a href="#"><i class="fa fa-facebook"></i></a></li>
                                          <li><a href="#"><i class="fa fa-twitter"></i></a></li>
                                          <li><a href="#"><i class="fa fa-google-plus"></i></a></li>
                                          <li><a href="#"><i class="fa fa-linkedin"></i></a></li>
                                          <li><a href="#"><i class="fa fa-skype"></i></a></li>
                                       </ul>

                                       </div>

                                    <div class="column member">

                                       <img src="images/team/team-img-03.jpg" alt=""/>

                                       <div class"member-name">
                                          <h5>Shikamaru Nara</h5>
                                          <span>Web Designer</span>
                                       </div>

                                       <p>Proin gravida nibh vel velit auctor aliquet. Aenean sollicitudin, lorem quis bibendum auctor,
                                         nisi elit consequat ipsum, nec sagittis sem nibh id elit. </p>

                                       <ul class="member-social">
                                          <li><a href="#"><i class="fa fa-facebook"></i></a></li>
                                          <li><a href="#"><i class="fa fa-twitter"></i></a></li>
                                          <li><a href="#"><i class="fa fa-google-plus"></i></a></li>
                                          <li><a href="#"><i class="fa fa-linkedin"></i></a></li>
                                          <li><a href="#"><i class="fa fa-skype"></i></a></li>
                                       </ul>

                                       </div>

                                 </div> <!-- Team wrapper End -->

                              </div> <!-- row End -->

                           </section> <!-- section end -->

                        </div> <!-- primary end -->

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

                              <div class="widget widget_contact">
                                      <h5>Address and Phone</h5>
                                      <p class="address">
                                          Sparrow Studio<br>
                                          1600 Amphitheatre Parkway <br>
                                          Mountain View, CA 94043 US<br>
                                          <span>(123) 456-7890</span>
                                      </p>

                                      <h5>Email and Social</h5>
                                      <p>
                                    E-mail: info{@}sparrow.com<br>
                                    Twitter: <a href="#">@sparrow</a><br>
                                    Facebook: <a href="#">sparrow FB Page</a><br>
                                    Google+: <a href="#">sparrow G+ Page</a>
                                 </p>
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

                        </div> <!-- secondary End-->

                     </div> <!-- page-content End-->

                  </div> <!-- Content End-->
            """#)
        }.html
    }
}
