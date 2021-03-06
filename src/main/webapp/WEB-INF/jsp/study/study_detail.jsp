<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
    <div class="study_detail_box">
    	<div class="d-flex justify-content-between mt-3">
    		<h1 class="font-weight-bold">${study.title}</h1>
    		<!-- 스크랩 박스 -->
    		
    		<div class="d-flex align-items-center">
	    		<span class="mr-2">스크랩</span>
	    		<a href="#" class="scrap-btn" data-study-id="${study.id}">
	    		<!-- 스크랩 버튼 비활성화 -->
	    		<c:if test="${scrapCheck eq false }">
	    			<img alt="scrap1" src="/static/images/not_scrap.png" width="30px" height="30px">
	    		</c:if>
	    		<!-- 스크랩 버튼 활성화 -->
	    		<c:if test="${scrapCheck eq true }">
	    			<img alt="scrap2" src="/static/images/scrap.jpg" width="25px" height="25px">
	    		</c:if>
	    		</a>
	    	</div>
    	</div>
    	<div class="d-flex justify-content-between">
    		<span class="font-weight-bold">
    			<fmt:formatDate value="${study.createdAt}" pattern="yyyy/MM/dd HH:mm" />
    		</span>
    		<span class="font-weight-bold">
    			<span>
    				마감일:
    				<fmt:parseDate value="${study.deadline }" var="parseDateValue" pattern="yyyy-MM-dd HH:mm:ss" />
					<fmt:formatDate value="${parseDateValue}" pattern="yyyy-MM-dd" />
    			</span>
    			<br>
   				마감까지 남은 기간:
   				<c:set var="today" value="<%=new java.util.Date()%>" />
				<!-- 현재날짜 -->
				<c:set var="date"><fmt:formatDate value="${today}" pattern="yyyy-MM-dd HH:mm:ss" /></c:set>
				<fmt:parseDate value="${date}" var="date1" pattern="yyyy-MM-dd HH:mm:ss"/>
				<fmt:parseNumber value="${date1.time / (1000*60*60*24)}" integerOnly="true" var="today"></fmt:parseNumber>
				<fmt:parseDate value="${study.deadline}" var="endPlanDate" pattern="yyyy-MM-dd HH:mm:ss"/>
				<fmt:parseNumber value="${endPlanDate.time / (1000*60*60*24)}" integerOnly="true" var="endDate"></fmt:parseNumber>
				<c:choose>
					<c:when test="${today- endDate > 0 }">
						<span class="text-danger font-weight-bold">
							D+${today - endDate}
						</span>
					</c:when>
					<c:when test="${today- endDate eq 0 }">
						<span class="text-danger font-weight-bold">D-day
						</span>
					</c:when>
					<c:when test="${today- endDate < 0 }">
						<span class="text-danger font-weight-bold">
							D
							${today - endDate}
						</span>
					</c:when>
				</c:choose>
    		</span>
    	</div>
    	<div class="d-flex justify-content-between mt-3">
    		<div>
	    		<span class="font-weight-bold">인원: ${joinCount}/${study.personnel }</span>
	    		<c:if test="${joinCount eq study.personnel}">
	    			<span class="font-weight-bold text-danger">모집 마감</span>
	    		</c:if>
    		</div>
    		<a href="#" id="joinBtn" data-study-id="${study.id}" class="">
    			<!--  신청인원보다 적을 때-->
    			<c:if test="${joinCheck eq false && joinCount < study.personnel}">
    				신청하기
    			</c:if>
    			<c:if test="${joinCheck eq true}">
    				신청취소
    			</c:if>	
    		</a>
    		<!-- 인원이 마감 되었고 스터디 모임에 참석하는 본인 아이디가 아닐 경우 신청 버튼 or 신청 취소 버튼 안보이게 하기  -->
    		<c:if test="${joinCount eq study.personnel && joinCheck eq true && joinUser.userId != userId}">
    			<script>
	    			$('#joinBtn').addClass('d-none');
    			</script>
	    		<span class="font-weight-bold">신청 마감</span>
	    	</c:if>
    	</div>
    	<div class="mt-3">
    		${study.content}
    	</div>
    	<hr>
    	
    	<!-- 댓글 공간 -->
    	<!-- 로그인 가능 상태만 쓰기 -->
    	<c:if test="${not empty userloginId }">
    		<div class="d-flex mt-2">
    			<input type="text" id="userComment${study.id}" class="form-control" placeholder="댓글 쓰기">
    			<!-- 스터디 글 번호 정보를 넘겨준다 스터디마다 id값이 다르므로 class로 이름을 지어준다 -->
    			<button type="button" class="userCommentBtn  btn btn-info ml-3" data-study-id="${study.id}">댓글 달기</button>
    		</div>
    	</c:if>
    	
		<c:forEach items="${commentViewList}" var="commentView">
    	<div class="commentBox form-control mt-2">
    		<div class="d-flex justify-content-between">
    			<span class="font-weight-bold">${commentView.user.loginId}</span>
    			<span><fmt:formatDate value="${commentView.comment.createdAt}" pattern="yyyy/MM/dd HH:mm" /></span>
    		</div>
    		<br>
    		${commentView.comment.content}
    	</div>
    	</c:forEach>
    	
    </div>
 <script>
 	$(document).ready(function(){
 		
 		// 댓글 게시 버튼 클릭시
 		$(".userCommentBtn").on("click",function(){
 			let studyId = $(this).data("study-id"); // 스터디 id값 확인
 			
 			let commentContent = $(this).siblings('input').val().trim(); //div안에있는 태그들
 			console.log(commentContent);
 			
 			if(commentContent == ""){
 				alert("댓글을 입력해주세요");
 				return;
 			}
 			
 			$.ajax({
 				type:"POST"
 				, url:"/comment/create"
 				, data:{"studyId":studyId,"content":commentContent}
 				, success: function(data) {
 					if(data.result == "success"){
 						location.reload();
 					} else {
 						alert(data.errorMessage);
 					}
 				}
 				, error: function(jqXHR, textStatus, errorThrown) {
 					let errorMsg = jqXHR.responseJSON.status;
 					alert(errorMsg + ":" + textStatus);
 				}
 			});
 		});
 		
 		// 스크랩
 		$(".scrap-btn").on("click", function(){
 			let studyId = $(this).data("study-id");
 			//alert(studyId);
 			
 			$.ajax({
 				url: "/scrap/" + studyId
 				,success: function(data) {
 					if (data.result == "success") {
 						location.reload();
 					} else {
 						alert(data.errorMessage);
 					}
 				}
 				,error: function(e) {
 					alert("스크랩에 실패하였습니다. 관리자에게 문의해주세요");
 				}
 			});
 		});
 		
 		//신청하기 버튼 클릭 시
 		$("#joinBtn").on("click", function(){
 			let studyId = $(this).data("study-id")
 			//alert(studyId);
 			
 			$.ajax({
 				type:"POST"
 				, url: "/join/apply"
 				, data:{"studyId":studyId}
 				, success: function(data) {
 					if(data.result == "success"){
 						location.reload();
 					} else {
 						alert(data.errorMessage)
 					}
 				}
 				, error: function(jqXHR, textStatus, errorThrown) {
 					let errorMsg = jqXHR.responseJSON.status;
 					alert(errorMsg + ":" + textStatus);
 				}
 			});
 		});
 	});
 </script>