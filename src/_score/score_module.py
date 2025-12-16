from scoring.module import ScoreModule

class PrivilegeWalk(ScoreModule):
    def check_answer(self, log):
        answers = self.get_question_by_item_id(log.item_id)["answers"]
        for answer in answers:
            if log.text == answer["text"]:
                return answer["value"]

        return 0

    def calculate_score(self):
        self.calculated_percent = 100
