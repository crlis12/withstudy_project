package com.withstudy.study;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@RequestMapping("study")
@Controller
public class StudyController {
	
	@RequestMapping("study_view")
	public String studyView(Model model) {
		
		model.addAttribute("viewName", "study/study");
		
		return "template/template";
	}
}
