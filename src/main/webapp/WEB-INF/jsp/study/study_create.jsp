<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <div id="study_create_form">
    	<form id="studyCreateForm" method="post" action="/study/study_create">
	    	<div class="mt-3">
    			<label for="title">제목</label>
    			<input type="text" id="title" name="title" class="form-control" placeholder="제목을 입력하세요">
    		</div>
    		<div class="d-flex justify-content-between mt-3">
	    		<div>
	    			<label for="personnel" >스터디 인원</label>
	    			<input type="text" id="personnel" name="personnel" class="form-control" placeholder="인원을 입력해세요">
	    		</div>
	    		<div class="ml-4">
	    			<label for="deadline">마감일자</label>
	    			<input type="text" id="deadline" name="deadline" class="form-control" placeholder="날짜">
	    		</div>
    		</div>
    		<div class="mt-3">
   				<label for="location">스터디 위치</label>
   				<input type="text" id="location" name="location" class="form-control" placeholder="위치">
   				<!-- Button trigger modal -->
				<button type="button" id="mycafelocation" class="btn btn-primary" data-toggle="modal" data-target="#myFullsizeModal">
  					모임 할 위치 정하기 					
				</button>
    		</div>
    		<div class="mt-3">
    			<label for="content">스터디 내용</label><br>
    			<textarea rows="10" cols="" id="content" name="content" class="form-control" placeholder="스터디 내용을 입력해주세요"></textarea>
    		</div>
    		<div class="d-flex justify-content-end mt-3">
    			<button type="button" id="studyCreateBtn" class="btn btn-info">스터디 만들기</button>
    		</div>
    	</form>
    </div>
    <!-- Fullsize Modal -->
    	<div class="modal fade" id="myFullsizeModal" tabindex="-1" role="dialog" aria-labelledby="myFullsizeModalLabel">
		  <div class="modal-dialog modal-lg" role="document">
		    <div class="modal-content modal-lg">
		      <div class="modal-header">
			    <h4 class="modal-title" id="myModalLabel">스터디할 위치 정하기</h4>
		        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
		      </div>
		      <div id="maploading" class="modal-body modal-lg">
		        <div class="map_wrap">	        	
    				<div id="map"></div>
				    <ul id="category">
				        <li id="CE7" data-order="4"> 
				            <span class="category_bg cafe"></span>
				            카페
				        </li>  
				    </ul>
				    <div id="menu_wrap" class="bg_white">
				        <div class="option">
				            <div>
				            	<!--  onsubmit="searchPlacesinput(); return false;  -->
				                <form onclick="relayout();" onsubmit="searchPlacesinput(); return false;">
				                    키워드 : <input type="text" value="이태원 맛집" id="keyword" size="15"> 
				                    <button type="button" id="searchBtnInput" class="btn btn-info">검색하기</button>
				                </form>
				            </div>
				        </div>
				        <hr>
				        <ul id="placesList"></ul>
				        <div id="pagination"></div>
				    </div>
				</div>
			</div>
		     <div class="modal-footer d-flex justify-content-between">
		      	<button type="button" id="mylocation" class="btn btn-info">내 현재 위치</button>
		        <button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
		     </div>
		    </div>
		  </div>
		  
		</div>
	<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=e9de3d5fc52b64f13d9c024aad18e8ec&libraries=services"></script>
	<script>
	// 마커를 클릭했을 때 해당 장소의 상세정보를 보여줄 커스텀오버레이입니다
	var placeOverlay = new kakao.maps.CustomOverlay({zIndex:1}), 
	    contentNode = document.createElement('div'), // 커스텀 오버레이의 컨텐츠 엘리먼트 입니다 
	    markers = [], // 마커를 담을 배열입니다
	    currCategory = ''; // 현재 선택된 카테고리를 가지고 있을 변수입니다
	 
	var mapContainer = document.getElementById('map'), // 지도를 표시할 div 
	    mapOption = {
	        center: new kakao.maps.LatLng(37.566826, 126.9786567), // 지도의 중심좌표
	        level: 3 // 지도의 확대 레벨
	    };
	
	// 지도를 생성합니다
	var map = new kakao.maps.Map(mapContainer, mapOption); 
	relayout();
	// 장소 검색 객체를 생성합니다
	var ps = new kakao.maps.services.Places(map); 
	
	//검색창----------
	// 키워드로 장소를 검색합니다
	$("#searchBtnInput").on('click', function(){
	var infowindow = new kakao.maps.InfoWindow({zIndex:1});
	
	function searchPlacesinput() {

	    var keyword = document.getElementById('keyword').value;

	    if (!keyword.replace(/^\s+|\s+$/g, '')) {
	        alert('키워드를 입력해주세요!');
	        return false;
	    }

	    // 장소검색 객체를 통해 키워드로 장소검색을 요청합니다
	    ps.keywordSearch( keyword, placesSearchCB); 
	}
	
	// 장소검색이 완료됐을 때 호출되는 콜백함수 입니다
	function placesSearchCB(data, status, pagination) {
	    if (status === kakao.maps.services.Status.OK) {

	        // 정상적으로 검색이 완료됐으면
	        // 검색 목록과 마커를 표출합니다
	        displayPlacesInput(data);

	        // 페이지 번호를 표출합니다
	        displayPaginationInput(pagination);

	    } else if (status === kakao.maps.services.Status.ZERO_RESULT) {

	        alert('검색 결과가 존재하지 않습니다.');
	        return;

	    } else if (status === kakao.maps.services.Status.ERROR) {

	        alert('검색 결과 중 오류가 발생했습니다.');
	        return;

	    }
	}
	
	
	
	function displayPlacesInput(places) {

	    var listEl = document.getElementById('placesList'), 
	    menuEl = document.getElementById('menu_wrap'),
	    fragment = document.createDocumentFragment(), 
	    bounds = new kakao.maps.LatLngBounds(), 
	    listStr = '';
	    
	    // 검색 결과 목록에 추가된 항목들을 제거합니다
	    removeAllChildNodsInput(listEl);

	    // 지도에 표시되고 있는 마커를 제거합니다
	    removeMarker();
	    
	    for ( var i=0; i<places.length; i++ ) {

	        // 마커를 생성하고 지도에 표시합니다
	        var placePosition = new kakao.maps.LatLng(places[i].y, places[i].x),
	            marker = addMarkerInput(placePosition, i), 
	            itemEl = getListItemInput(i, places[i]); // 검색 결과 항목 Element를 생성합니다
			
	        // 검색된 장소 위치를 기준으로 지도 범위를 재설정하기위해
	        // LatLngBounds 객체에 좌표를 추가합니다
	        bounds.extend(placePosition);

	        // 마커와 검색결과 항목에 mouseover 했을때
	        // 해당 장소에 인포윈도우에 장소명을 표시합니다
	        // mouseout 했을 때는 인포윈도우를 닫습니다
	        (function(marker, title) {
	            kakao.maps.event.addListener(marker, 'mouseover', function() {
	                displayInfowindowInput(marker, title);
	            });

	            kakao.maps.event.addListener(marker, 'mouseout', function() {
	                infowindow.close();
	            });

	            itemEl.onmouseover =  function () {
	                displayInfowindowInput(marker, title);
	            };

	            itemEl.onmouseout =  function () {
	                infowindow.close();
	            };
	        })(marker, places[i].place_name);

	        fragment.appendChild(itemEl);
	        
	        (function(marker, place) {
            	relayout();
                kakao.maps.event.addListener(marker, 'click', function() {
                    displayPlaceInfo(place);
                });
            })(marker, places[i]);
	    }

	    // 검색결과 항목들을 검색결과 목록 Element에 추가합니다
	    listEl.appendChild(fragment);
	    menuEl.scrollTop = 0;

	    // 검색된 장소 위치를 기준으로 지도 범위를 재설정합니다
	    map.setBounds(bounds);
	}
	
	// 검색결과 목록 하단에 페이지번호를 표시는 함수입니다
	function displayPaginationInput(pagination) {
	    var paginationEl = document.getElementById('pagination'),
	        fragment = document.createDocumentFragment(),
	        i; 

	    // 기존에 추가된 페이지번호를 삭제합니다
	    while (paginationEl.hasChildNodes()) {
	        paginationEl.removeChild (paginationEl.lastChild);
	    }

	    for (i=1; i<=pagination.last; i++) {
	        var el = document.createElement('a');
	        el.href = "#";
	        el.innerHTML = i;

	        if (i===pagination.current) {
	            el.className = 'on';
	        } else {
	            el.onclick = (function(i) {
	                return function() {
	                    pagination.gotoPage(i);
	                }
	            })(i);
	        }

	        fragment.appendChild(el);
	    }
	    paginationEl.appendChild(fragment);
	}
	
	// 검색결과 목록 또는 마커를 클릭했을 때 호출되는 함수입니다
	// 인포윈도우에 장소명을 표시합니다
	function displayInfowindowInput(marker, title) {
	    var content = '<div style="padding:5px;z-index:1;">' + title + '</div>';

	    infowindow.setContent(content);
	    infowindow.open(map, marker);
	}

	 // 검색결과 목록의 자식 Element를 제거하는 함수입니다
	function removeAllChildNodsInput(el) {   
	    while (el.hasChildNodes()) {
	        el.removeChild (el.lastChild);
	    }
	}
	 
	// 검색결과 항목을 Element로 반환하는 함수입니다
	function getListItemInput(index, places) {

	    var el = document.createElement('li'),
	    itemStr = '<span class="markerbg marker_' + (index+1) + '"></span>' +
	                '<div class="info">' +
	                '   <h5>' + places.place_name + '</h5>';

	    if (places.road_address_name) {
	        itemStr += '    <span>' + places.road_address_name + '</span>' +
	                    '   <span class="jibun gray">' +  places.address_name  + '</span>';
	    } else {
	        itemStr += '    <span>' +  places.address_name  + '</span>'; 
	    }
	                 
	      itemStr += '  <span class="tel">' + places.phone  + '</span>' +
	                '</div>';           

	    el.innerHTML = itemStr;
	    el.className = 'item';

	    return el;
	}
	
	// 마커를 생성하고 지도 위에 마커를 표시하는 함수입니다
	function addMarkerInput(position, idx, title) {
	    var imageSrc = 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_number_blue.png', // 마커 이미지 url, 스프라이트 이미지를 씁니다
	        imageSize = new kakao.maps.Size(36, 37),  // 마커 이미지의 크기
	        imgOptions =  {
	            spriteSize : new kakao.maps.Size(36, 691), // 스프라이트 이미지의 크기
	            spriteOrigin : new kakao.maps.Point(0, (idx*46)+10), // 스프라이트 이미지 중 사용할 영역의 좌상단 좌표
	            offset: new kakao.maps.Point(13, 37) // 마커 좌표에 일치시킬 이미지 내에서의 좌표
	        },
	        markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize, imgOptions),
	            marker = new kakao.maps.Marker({
	            position: position, // 마커의 위치
	            image: markerImage 
	        });

	    marker.setMap(map); // 지도 위에 마커를 표출합니다
	    markers.push(marker);  // 배열에 생성된 마커를 추가합니다

	    return marker;
	}
	
	searchPlacesinput();
	});
	// ----- 검색창 ---------------
	
	// 지도에 idle 이벤트를 등록합니다
	kakao.maps.event.addListener(map, 'idle', searchPlaces);

	// 커스텀 오버레이의 컨텐츠 노드에 css class를 추가합니다 
	contentNode.className = 'placeinfo_wrap';

	// 커스텀 오버레이의 컨텐츠 노드에 mousedown, touchstart 이벤트가 발생했을때
	// 지도 객체에 이벤트가 전달되지 않도록 이벤트 핸들러로 kakao.maps.event.preventMap 메소드를 등록합니다 
	addEventHandle(contentNode, 'mousedown', kakao.maps.event.preventMap);
	addEventHandle(contentNode, 'touchstart', kakao.maps.event.preventMap);

	// 커스텀 오버레이 컨텐츠를 설정합니다
	placeOverlay.setContent(contentNode);  

	// 각 카테고리에 클릭 이벤트를 등록합니다
	addCategoryClickEvent();

	//카페 이름과 주소입니다
	let cafeName = null;
	let cafeaddress= null;

	// 엘리먼트에 이벤트 핸들러를 등록하는 함수입니다
	function addEventHandle(target, type, callback) {
	    if (target.addEventListener) {
	        target.addEventListener(type, callback);
	    } else {
	        target.attachEvent('on' + type, callback);
	    }
	}

	// 카테고리 검색을 요청하는 함수입니다
	function searchPlaces() {
	    if (!currCategory) {
	        return;
	    }
	    
	    // 커스텀 오버레이를 숨깁니다 
	    placeOverlay.setMap(null);

	    // 지도에 표시되고 있는 마커를 제거합니다
	    removeMarker();
	    
	    ps.categorySearch(currCategory, placesSearchCB, {useMapBounds:true}); 
	}

	// 장소검색이 완료됐을 때 호출되는 콜백함수 입니다
	function placesSearchCB(data, status, pagination) {
	    if (status === kakao.maps.services.Status.OK) {

	        // 정상적으로 검색이 완료됐으면 지도에 마커를 표출합니다
	        displayPlaces(data);
	    } else if (status === kakao.maps.services.Status.ZERO_RESULT) {
	        // 검색결과가 없는경우 해야할 처리가 있다면 이곳에 작성해 주세요

	    } else if (status === kakao.maps.services.Status.ERROR) {
	        // 에러로 인해 검색결과가 나오지 않은 경우 해야할 처리가 있다면 이곳에 작성해 주세요
	    }
	}

	// 지도에 마커를 표출하는 함수입니다
	function displayPlaces(places) {
	    // 몇번째 카테고리가 선택되어 있는지 얻어옵니다
	    // 이 순서는 스프라이트 이미지에서의 위치를 계산하는데 사용됩니다
	    var order = document.getElementById(currCategory).getAttribute('data-order');
	    for ( var i=0; i<places.length; i++ ) {

	            // 마커를 생성하고 지도에 표시합니다
	            var marker = addMarker(new kakao.maps.LatLng(places[i].y, places[i].x), order);

	            // 마커와 검색결과 항목을 클릭 했을 때
	            // 장소정보를 표출하도록 클릭 이벤트를 등록합니다
	            (function(marker, place) {
	            	relayout();
	                kakao.maps.event.addListener(marker, 'click', function() {
	                    displayPlaceInfo(place);
	                });
	            })(marker, places[i]);
	    }
	}

	// 마커를 생성하고 지도 위에 마커를 표시하는 함수입니다
	function addMarker(position, order) {
	    var imageSrc = 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/places_category.png', // 마커 이미지 url, 스프라이트 이미지를 씁니다
	        imageSize = new kakao.maps.Size(27, 28),  // 마커 이미지의 크기
	        imgOptions =  {
	            spriteSize : new kakao.maps.Size(72, 208), // 스프라이트 이미지의 크기
	            spriteOrigin : new kakao.maps.Point(46, (order*36)), // 스프라이트 이미지 중 사용할 영역의 좌상단 좌표
	            offset: new kakao.maps.Point(11, 28) // 마커 좌표에 일치시킬 이미지 내에서의 좌표
	        },
	        markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize, imgOptions),
	            marker = new kakao.maps.Marker({
	            position: position, // 마커의 위치
	            image: markerImage 
	        });
	    marker.setMap(map); // 지도 위에 마커를 표출합니다
	    markers.push(marker);  // 배열에 생성된 마커를 추가합니다

	    return marker;
	}
	
	// 지도 위에 표시되고 있는 마커를 모두 제거합니다
	function removeMarker() {
		relayout();
	    for ( var i = 0; i < markers.length; i++ ) {
	        markers[i].setMap(null);
	    }   
	    markers = [];
	}

	// 클릭한 마커에 대한 장소 상세정보를 커스텀 오버레이로 표시하는 함수입니다
	function displayPlaceInfo (place) {
		
	    var content = '<div class="placeinfo">' +
	                    '   <a class="title" href="' + place.place_url + '" target="_blank" title="' + place.place_name + '">' + place.place_name + '</a>';   

	    if (place.road_address_name) {
	        content += '    <span title="' + place.road_address_name + '">' + place.road_address_name + '</span>' +
	                    '  <span class="jibun" title="' + place.address_name + '">(지번 : ' + place.address_name + ')</span>';
	    }  else {
	        content += '    <span title="' + place.address_name + '">' + place.address_name + '</span>';
	        let cafeaddress = content;
	    }                
	   
	    content += '    <span class="tel">' + place.phone  +'</span>' +
	    			'<button type="button" id="studylocation" class="btn btn-success" data-dismiss="modal">여기로 스터디 모임  </button>' +
	                '</div>' + 
	                '<div class="after"></div>';

	    contentNode.innerHTML = content;
	    placeOverlay.setPosition(new kakao.maps.LatLng(place.y, place.x));
	    placeOverlay.setMap(map);
	    
	    // 카페이름, 카페 주소
	    console.log(place.place_name,place.road_address_name);
	    
	    
	    // 지도에서 카페 위치 선택했을 때
	    $("#studylocation").on("click", function(){
	    	cafeName = place.place_name;
	        cafeaddress = place.road_address_name;
	        console.log(cafeName);
	        console.log(cafeaddress);
	        $("#location").val(cafeName + "(" + cafeaddress + ")");
		});
	}


	// 각 카테고리에 클릭 이벤트를 등록합니다
	function addCategoryClickEvent() {
	    var category = document.getElementById('category'),
	        children = category.children;

	    for (var i=0; i<children.length; i++) {
	        children[i].onclick = onClickCategory;
	    }
	}
	
	//지도 크기 변경되었을때 호출
	function relayout() {    
	    
	    // 지도를 표시하는 div 크기를 변경한 이후 지도가 정상적으로 표출되지 않을 수도 있습니다
	    // 크기를 변경한 이후에는 반드시  map.relayout 함수를 호출해야 합니다 
	    // window의 resize 이벤트에 의한 크기변경은 map.relayout 함수가 자동으로 호출됩니다
	    map.relayout();
	}

	// 카테고리를 클릭했을 때 호출되는 함수입니다
	function onClickCategory() {
	    var id = this.id,
	        className = this.className;
	    
	    placeOverlay.setMap(null);

	    if (className === 'on') {
	        currCategory = '';
	        changeCategoryClass();
	        removeMarker();
	    } else {
	        currCategory = id;
	        changeCategoryClass(this);
	        searchPlaces();
	    }
	}

	// 클릭된 카테고리에만 클릭된 스타일을 적용하는 함수입니다
	function changeCategoryClass(el) {
	    var category = document.getElementById('category'),
	        children = category.children,
	        i;

	    for ( i=0; i<children.length; i++ ) {
	        children[i].className = '';
	    }

	    if (el) {
	        el.className = 'on';
	    } 
	}
	map.relayout();	
	</script>
<script>
	$(document).ready(function(){
		relayout();
		$("#mycafelocation").on("click", function(){
			relayout();
		});

		$("#deadline").datepicker({
			dateFormat: "yy-mm-dd"
			, minDate: 0
		});
		$("#studyCreateBtn").on('click', function(){
			let title = $("#title").val().trim();
			let personnel = $("#personnel").val().trim();
			let location = $("#location").val().trim();
			let deadline = $("#deadline").val().trim();
			let content = $("#content").val().trim();
			
			if(title == "") {
				alert("제목을 입력하세요");
				return;
			}
			if(personnel == "") {
				alert("인원을 입력하세요");
				return;
			}
			if(deadline == "") {
				alert("마감일자를 입력하세요");
				return;
			}
			if(location == "") {
				alert("스터디 모임을 할 위치을 입력하세요");
				return;
			}
			
			let url = $("#studyCreateForm").attr("action");
			let params = $("#studyCreateForm").serialize();
			
			console.log(url);
			console.log(params);
			
			$.post(url, params)
			.done(function(data){
				if(data.result == "success"){
					alert("스터디 모임이 만들어졌습니다.");
					window.location.href="/study/study_view";
				} else {
					alert(data.errorMessage);
				}
			});
		});
		
		$("#mylocation").on("click", function(){
			relayout();
			//나의 현재 위치
			function locationLoadSuccess(pos){
			    // 현재 위치 받아오기
				var currentPos = new kakao.maps.LatLng(pos.coords.latitude,pos.coords.longitude);
			    
				console.log(currentPos)
			    // 지도 이동(기존 위치와 가깝다면 부드럽게 이동)
			    map.panTo(currentPos);

			    // 마커 생성
			    var marker = new kakao.maps.Marker({
			        position: currentPos
			    });
			    
			    var infowindow = new kakao.maps.InfoWindow({
				    content : '<div style="padding:4px" class="text-center">나의 현재 위치</div>' // 인포윈도우에 표시할 내용
				});

				// 인포윈도우를 지도에 표시한다
				infowindow.open(map, marker);

			    // 기존에 마커가 있다면 제거
			    marker.setMap(null);
			    marker.setMap(map);
			};
			
			function locationLoadError(pos){
			    alert('위치 정보를 가져오는데 실패했습니다.');
			};
			navigator.geolocation.getCurrentPosition(locationLoadSuccess,locationLoadError);	
		});
		$("mycafelocation").on("click", function(){
			map.relayout();
		});
	});
</script>