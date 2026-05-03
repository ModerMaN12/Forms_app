def generate_survey_html(survey) -> str:
    questions_html = ""
    for q in sorted(survey.questions, key=lambda x: x.order):
        required_mark = 'required' if q.is_required else ''
        req_star = '*' if q.is_required else ''

        if q.question_type == "single_choice":
            options = ""
            if q.options:
                for i, opt in enumerate(q.options):
                    options += f'''
                    <label class="option">
                        <input type="radio" name="q_{q.id}" value="{opt}" {required_mark}>
                        <span>{opt}</span>
                    </label>'''
            questions_html += f'''
            <div class="question">
                <p class="question-text">{q.text} <span class="req">{req_star}</span></p>
                <div class="options">{options}</div>
            </div>'''

        elif q.question_type == "multiple_choice":
            options = ""
            if q.options:
                for opt in q.options:
                    options += f'''
                    <label class="option">
                        <input type="checkbox" name="q_{q.id}[]" value="{opt}">
                        <span>{opt}</span>
                    </label>'''
            questions_html += f'''
            <div class="question">
                <p class="question-text">{q.text} <span class="req">{req_star}</span></p>
                <div class="options">{options}</div>
            </div>'''

        elif q.question_type == "text":
            questions_html += f'''
            <div class="question">
                <p class="question-text">{q.text} <span class="req">{req_star}</span></p>
                <textarea name="q_{q.id}" rows="3" placeholder="Your answer..." {required_mark}></textarea>
            </div>'''

        elif q.question_type == "rating":
            stars = ""
            for i in range(1, 6):
                stars += f'<label class="star"><input type="radio" name="q_{q.id}" value="{i}" {required_mark}><span>&#9733;</span></label>'
            questions_html += f'''
            <div class="question">
                <p class="question-text">{q.text} <span class="req">{req_star}</span></p>
                <div class="stars">{stars}</div>
            </div>'''

        elif q.question_type == "scale":
            scale_inputs = ""
            for i in range(1, 11):
                scale_inputs += f'<label><input type="radio" name="q_{q.id}" value="{i}" {required_mark}>{i}</label>'
            questions_html += f'''
            <div class="question">
                <p class="question-text">{q.text} <span class="req">{req_star}</span></p>
                <div class="scale">{scale_inputs}</div>
            </div>'''

    name_field = ""
    if survey.access_type == "anonymous":
        name_field = '''
        <div class="question">
            <p class="question-text">Your name (optional)</p>
            <input type="text" name="respondent_name" placeholder="Enter your name">
        </div>'''

    html = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{survey.title}</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f5f5; color: #333; line-height: 1.6; }}
        .container {{ max-width: 640px; margin: 0 auto; padding: 24px 16px; }}
        .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 32px 24px; border-radius: 12px; margin-bottom: 24px; }}
        .header h1 {{ font-size: 24px; margin-bottom: 8px; }}
        .header p {{ opacity: 0.9; font-size: 14px; }}
        .question {{ background: white; padding: 20px; border-radius: 10px; margin-bottom: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.08); }}
        .question-text {{ font-weight: 600; margin-bottom: 12px; font-size: 15px; }}
        .req {{ color: #e74c3c; }}
        .option {{ display: flex; align-items: center; padding: 10px 12px; border-radius: 8px; cursor: pointer; transition: background 0.15s; margin-bottom: 4px; }}
        .option:hover {{ background: #f0f0f0; }}
        .option input {{ margin-right: 12px; accent-color: #667eea; }}
        textarea, input[type="text"] {{ width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px; font-family: inherit; }}
        textarea:focus, input:focus {{ outline: none; border-color: #667eea; }}
        .stars {{ display: flex; gap: 8px; }}
        .stars input {{ display: none; }}
        .stars span {{ font-size: 32px; cursor: pointer; color: #ddd; transition: color 0.15s; }}
        .stars label:hover span, .stars input:checked ~ label span {{ color: #f1c40f; }}
        .scale {{ display: flex; gap: 8px; flex-wrap: wrap; }}
        .scale label {{ display: flex; flex-direction: column; align-items: center; padding: 8px 12px; border: 2px solid #ddd; border-radius: 8px; cursor: pointer; min-width: 44px; transition: all 0.15s; }}
        .scale label:hover {{ border-color: #667eea; }}
        .scale input {{ display: none; }}
        .scale input:checked + label, .scale label:has(input:checked) {{ border-color: #667eea; background: #667eea; color: white; }}
        .submit-btn {{ width: 100%; padding: 14px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; border-radius: 10px; font-size: 16px; font-weight: 600; cursor: pointer; transition: opacity 0.15s; }}
        .submit-btn:hover {{ opacity: 0.9; }}
        .success {{ text-align: center; padding: 40px; }}
        .success h2 {{ color: #27ae60; margin-bottom: 12px; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>{survey.title}</h1>
            <p>{survey.description}</p>
        </div>
        <form id="surveyForm" action="/api/responses/{survey.id}" method="POST">
            {name_field}
            {questions_html}
            <button type="submit" class="submit-btn">Submit</button>
        </form>
    </div>
    <script>
        document.getElementById('surveyForm').addEventListener('submit', async function(e) {{
            e.preventDefault();
            const formData = new FormData(this);
            const answers = [];
            const questions = document.querySelectorAll('.question');
            questions.forEach(q => {{
                const text = q.querySelector('.question-text');
                const radios = q.querySelectorAll('input[type="radio"]');
                const checkboxes = q.querySelectorAll('input[type="checkbox"]');
                const textarea = q.querySelector('textarea');
                const textInput = q.querySelector('input[type="text"]');
                const qId = radios[0]?.name?.replace('q_', '') || checkboxes[0]?.name?.replace('q_[]', '') || textarea?.name || textInput?.name;
                if (!qId || qId === 'respondent_name') return;
                if (radios.length > 0) {{
                    const checked = q.querySelector('input[type="radio"]:checked');
                    if (checked) answers.push({{question_id: parseInt(qId), value: checked.value}});
                }} else if (checkboxes.length > 0) {{
                    const checked = Array.from(q.querySelectorAll('input[type="checkbox"]:checked')).map(c => c.value);
                    if (checked.length > 0) answers.push({{question_id: parseInt(qId), value: checked}});
                }} else if (textarea) {{
                    answers.push({{question_id: parseInt(qId), value: textarea.value}});
                }}
            }});
            const body = {{
                respondent_name: formData.get('respondent_name') || null,
                answers: answers
            }};
            try {{
                const res = await fetch(this.action, {{
                    method: 'POST',
                    headers: {{'Content-Type': 'application/json'}},
                    body: JSON.stringify(body)
                }});
                if (res.ok) {{
                    document.querySelector('.container').innerHTML = '<div class="success"><h2>Thank you!</h2><p>Your response has been submitted.</p></div>';
                }} else {{
                    const err = await res.json();
                    alert(err.detail || 'Error submitting response');
                }}
            }} catch(err) {{
                alert('Network error');
            }}
        }});
    </script>
</body>
</html>'''
    return html
